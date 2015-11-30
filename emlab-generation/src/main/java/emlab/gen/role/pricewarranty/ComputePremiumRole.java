/*******************************************************************************
 * Copyright 2013 the original author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/
package emlab.gen.role.pricewarranty;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import org.apache.commons.math.stat.regression.SimpleRegression;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.annotation.Transient;
import org.springframework.data.neo4j.support.Neo4jTemplate;
import org.springframework.transaction.annotation.Transactional;

import agentspring.role.Role;
import agentspring.role.RoleComponent;
import emlab.gen.domain.agent.DecarbonizationModel;
import emlab.gen.domain.agent.EnergyProducer;
import emlab.gen.domain.agent.Government;
import emlab.gen.domain.agent.Regulator;
import emlab.gen.domain.gis.Zone;
import emlab.gen.domain.market.CO2Auction;
import emlab.gen.domain.market.ClearingPoint;
import emlab.gen.domain.market.electricity.ElectricitySpotMarket;
import emlab.gen.domain.market.electricity.Segment;
import emlab.gen.domain.market.electricity.SegmentLoad;
import emlab.gen.domain.policy.renewablesupport.BaseCostFip;
import emlab.gen.domain.policy.renewablesupport.BiasFactor;
import emlab.gen.domain.policy.renewablesupport.RenewableSupportFipScheme;
import emlab.gen.domain.policy.renewablesupport.RenewableTargetForTender;
import emlab.gen.domain.technology.PowerGeneratingTechnology;
import emlab.gen.domain.technology.PowerGridNode;
import emlab.gen.domain.technology.PowerPlant;
import emlab.gen.domain.technology.Substance;
import emlab.gen.domain.technology.SubstanceShareInFuelMix;
import emlab.gen.repository.Reps;
import emlab.gen.role.AbstractEnergyProducerRole;

/**
 * @author Kaveri3012 This role loops through eligible technologies, eligible
 *         nodes,
 * 
 *         computes LCOE per technology per node and creates an object,
 *         BaseCost, to store it.
 * 
 *         In technology neutral mode, after computing LCOE per technology, it
 *         should store LCOE per technology and create a merit order upto which
 *         a cetrain target is filled.
 * 
 */

@RoleComponent
public class ComputePremiumRole extends AbstractEnergyProducerRole<EnergyProducer>implements Role<EnergyProducer> {

    @Transient
    @Autowired
    Reps reps;

    @Transient
    @Autowired
    Neo4jTemplate template;

    @SuppressWarnings("unchecked")
    @Transactional
    public void act(RenewableSupportFipScheme scheme) {

        Regulator regulator = scheme.getRegulator();

        // should be close to the investor's future time point.
        long futureTimePoint = scheme.getFutureSchemeStartTime() + getCurrentTick();

        ElectricitySpotMarket eMarket = reps.marketRepository.findElectricitySpotMarketForZone(regulator.getZone());

        Iterable<PowerGeneratingTechnology> eligibleTechnologies = scheme.getPowerGeneratingTechnologiesEligible();

        for (PowerGeneratingTechnology technology : eligibleTechnologies) {
            // for (PowerGeneratingTechnology technology :
            // reps.powerGeneratingTechnologyRepository.findAll()) {
            DecarbonizationModel model = reps.genericRepository.findAll(DecarbonizationModel.class).iterator().next();
            if (technology.isIntermittent() && model.isNoPrivateIntermittentRESInvestment())
                continue;
            // logger.warn(
            // "Calculating for " + technology.getName() + ", for Nodes: " +
            // possibleInstallationNodes.toString());

            for (PowerGridNode node : reps.powerGridNodeRepository.findAllPowerGridNodesByZone(regulator.getZone())) {

                // or create a new power plant if above statement returns null,
                // and assign it to a random energy producer.
                PowerPlant plant = new PowerPlant();

                EnergyProducer producer = reps.energyProducerRepository.findAll().iterator().next();

                plant.specifyNotPersist(getCurrentTick(), producer, node, technology);
                // logger.warn("creating a new power plant for " +
                // producer.getName() + ", of technology "
                // + plant.getTechnology().getName() + ", with node" +
                // node.getName() + "for time "
                // + futureTimePoint);

                // ==== Expectations ===

                Map<Substance, Double> expectedFuelPrices = predictFuelPrices(producer, futureTimePoint);
                logger.warn("expected fuel prices" + expectedFuelPrices);

                // CO2
                Map<ElectricitySpotMarket, Double> expectedCO2Price = determineExpectedCO2PriceInclTaxAndFundamentalForecast(
                        futureTimePoint, producer.getNumberOfYearsBacklookingForForecasting(), 0, getCurrentTick());
                logger.warn("expected CO2 price" + expectedCO2Price);

                double annualMarginalCost = 0d;
                double totalGenerationinMWh = 0d;
                double lcoe = 0d;

                Map<Substance, Double> myFuelPrices = new HashMap<Substance, Double>();
                for (Substance fuel : technology.getFuels()) {
                    myFuelPrices.put(fuel, expectedFuelPrices.get(fuel));
                }
                Set<SubstanceShareInFuelMix> fuelMix = calculateFuelMix(plant, myFuelPrices,
                        expectedCO2Price.get(eMarket));
                plant.setFuelMix(fuelMix);

                double expectedMarginalCost = determineExpectedMarginalCost(plant, expectedFuelPrices,
                        expectedCO2Price.get(eMarket));
                logger.warn("expected marginal cost in fip role for plant " + plant + "is " + expectedMarginalCost);

                totalGenerationinMWh = plant.getAnnualFullLoadHours() * plant.getActualNominalCapacity();
                annualMarginalCost = totalGenerationinMWh * expectedMarginalCost;

                // logger.warn("for technology " +
                // plant.getTechnology().getName() + " total generation is "
                // + totalGenerationinMWh + " and running hours is " +
                // fullLoadHours);

                double fixedOMCost = calculateFixedOperatingCost(plant, getCurrentTick());
                double operatingCost = fixedOMCost + annualMarginalCost;

                long durationOfSupportScheme = scheme.getSupportSchemeDuration();
                long finishedConstruction = plant.calculateActualPermittime() + plant.calculateActualLeadtime();

                // logger.warn("Fixed OM cost for technology " +
                // plant.getTechnology().getName() + " is " + fixedOMCost
                // + " and operatingCost is " + operatingCost);

                TreeMap<Integer, Double> discountedProjectCapitalOutflow = calculateSimplePowerPlantInvestmentCashFlow(
                        (int) technology.getDepreciationTime(), (int) plant.getActualLeadTime(),
                        plant.getActualInvestedCapital(), 0);

                // Creation of in cashflow during operation
                TreeMap<Integer, Double> discountedProjectCashOutflow = calculateSimplePowerPlantInvestmentCashFlow(
                        (int) technology.getDepreciationTime(), (int) plant.getActualLeadTime(), 0, operatingCost);

                TreeMap<Integer, Double> factorDiscountedGenerationSeries = calculateSimplePowerPlantInvestmentCashFlow(
                        (int) durationOfSupportScheme, (int) plant.getActualLeadTime(), 0, 1);

                // Calculation of weighted average cost of capital,
                // based on regulator's assumption of companies debt-ratio
                double wacc = (1 - regulator.getDebtRatioOfInvestments()) * regulator.getEquityInterestRate()
                        + regulator.getDebtRatioOfInvestments() * regulator.getLoanInterestRate();

                double discountedCapitalCosts = npv(discountedProjectCapitalOutflow, wacc);
                // logger.warn("discountedCapitalCosts " +
                // discountedCapitalCosts);
                double discountedOpCost = npv(discountedProjectCashOutflow, wacc);
                double factorDiscountedGeneration = npv(factorDiscountedGenerationSeries, wacc);
                // logger.warn("discountedOpCost " + discountedOpCost);
                BiasFactor biasFactor = reps.renewableSupportSchemeRepository
                        .findBiasFactorGivenTechnologyNodeAndScheme(technology.getName(), node.getName(), scheme);

                if (scheme.isCostContainmentMechanismEnabled()) {
                    computeDegressionAndResetBiasFactor(scheme, biasFactor);
                }

                // FOR VERIFICATION
                double projectCost = discountedCapitalCosts + discountedOpCost;
                logger.warn("discountedOpCost in FipRole is" + discountedOpCost + "total Generation is"
                        + totalGenerationinMWh + "flh is" + plant.getAnnualFullLoadHours());
                logger.warn("discountedCapCost in FipRole is " + discountedCapitalCosts);

                double biasFactorValue = biasFactor.getFeedInPremiumBiasFactor();
                lcoe = (discountedCapitalCosts + discountedOpCost) * biasFactorValue
                        / (totalGenerationinMWh * factorDiscountedGeneration);
                logger.warn(
                        "expectedBaseCost in fipRole for plant" + plant + "in tick" + futureTimePoint + "is " + lcoe);

                BaseCostFip baseCostFip = new BaseCostFip();

                baseCostFip.setCostPerMWh(lcoe);
                baseCostFip.setStartTime(futureTimePoint);
                baseCostFip.setNode(node);
                baseCostFip.setTechnology(technology);
                baseCostFip.setEndTime(futureTimePoint + scheme.getSupportSchemeDuration());
                baseCostFip.persist();

                // logger.warn("LCOE in per MWH for technology " +
                // plant.getTechnology().getName() + "for node "
                // + baseCostFip.getNode().getNodeId() + " is , " +
                // baseCostFip.getCostPerMWh());

            }
        }

    }

    private void computeDegressionAndResetBiasFactor(RenewableSupportFipScheme scheme, BiasFactor biasFactor) {

        // get target value of renewable generation
        double renewableTargetInMwh = computeRenewableGenerationTarget(scheme);
        double generationFromRenewables = totalExpectedGenerationFromRenewables(scheme);
        double degressionFactor = biasFactor.getDegressionFactor();

        logger.warn("generationFromRenewables; " + generationFromRenewables);
        logger.warn("renewableTargetInMwh; " + renewableTargetInMwh);

        if (generationFromRenewables >= renewableTargetInMwh) {
            double newBiasFactor = biasFactor.getFeedInPremiumBiasFactor() * (1 - degressionFactor);
            biasFactor.setFeedInPremiumBiasFactor(newBiasFactor);
            logger.warn("DEGRESSING!!!");
        }
        // if expected generation exceeds target, degress by a certain
        // percentage.
        // else if expected generation is lower than a certain margin, increase
        // bias factor. - will have to create targetLowerMargin and
        // targetUpperMargin for it, best created in target object.

    }

    private double computeRenewableGenerationTarget(RenewableSupportFipScheme scheme) {
        double demandFactor;
        double targetFactor;
        Zone zone = scheme.getRegulator().getZone();

        logger.warn("Calculate Renewable Target Role started of zone: " + zone);

        ElectricitySpotMarket market = reps.marketRepository.findElectricitySpotMarketForZone(zone);

        // get demand factor
        demandFactor = market.getDemandGrowthTrend().getValue(getCurrentTick() + scheme.getFutureSchemeStartTime());
        /*
         * it aggregates segments from both countries, so the boolean should
         * actually be true here and the code adjusted to FALSE case. Or a query
         * should be adjusted what probably will take less time.
         */

        // get renewable energy target in factor (percent)
        RenewableTargetForTender target = reps.renewableTargetForTenderRepository
                .findRenewableTargetForTenderByRegulator(scheme.getRegulator());

        targetFactor = target.getYearlyRenewableTargetTimeSeries()
                .getValue(getCurrentTick() + scheme.getFutureSchemeStartTime());
                // logger.warn("targetFactor is " + targetFactor);

        // get totalLoad in MWh
        double totalExpectedConsumption = 0d;

        for (SegmentLoad segmentLoad : market.getLoadDurationCurve()) {
            // logger.warn("segmentLoad: " + segmentLoad);
            totalExpectedConsumption += segmentLoad.getBaseLoad() * demandFactor
                    * segmentLoad.getSegment().getLengthInHours();

            // logger.warn("demand factor is: " + demandFactor);

        }
        logger.warn("totalExpectedConsumption; " + totalExpectedConsumption);
        // renewable target for tender operation start year in MWh is
        double renewableTargetInMwh = targetFactor * totalExpectedConsumption;

        return renewableTargetInMwh;
    }

    public double determineExpectedMarginalCost(PowerPlant plant, Map<Substance, Double> expectedFuelPrices,
            double expectedCO2Price) {
        double mc = determineExpectedMarginalFuelCost(plant, expectedFuelPrices);
        double co2Intensity = plant.calculateEmissionIntensity();
        mc += co2Intensity * expectedCO2Price;
        return mc;
    }

    public double determineExpectedMarginalFuelCost(PowerPlant powerPlant, Map<Substance, Double> expectedFuelPrices) {
        double fc = 0d;
        for (SubstanceShareInFuelMix mix : powerPlant.getFuelMix()) {
            double amount = mix.getShare();
            double fuelPrice = expectedFuelPrices.get(mix.getSubstance());
            fc += amount * fuelPrice;
        }
        return fc;
    }

    private double totalExpectedGenerationFromRenewables(RenewableSupportFipScheme scheme) {

        double totalExpectedGeneration = 0d;
        double expectedGenerationPerTechnology = 0d;
        double expectedGenerationPerPlant = 0d;
        long numberOfSegments = reps.segmentRepository.count();
        // logger.warn("numberOfsegments: " + numberOfSegments);
        ElectricitySpotMarket market = reps.marketRepository
                .findElectricitySpotMarketForZone(scheme.getRegulator().getZone());

        for (PowerGeneratingTechnology technology : scheme.getPowerGeneratingTechnologiesEligible()) {
            expectedGenerationPerTechnology = 0d;
            for (PowerPlant plant : reps.powerPlantRepository.findOperationalPowerPlantsByMarketAndTechnology(market,
                    technology, getCurrentTick() + scheme.getFutureSchemeStartTime())) {
                expectedGenerationPerPlant = 0d;
                for (Segment segment : reps.segmentRepository.findAll()) {
                    double availablePlantCapacity = plant.getAvailableCapacity(
                            getCurrentTick() + scheme.getFutureSchemeStartTime(), segment, numberOfSegments);
                    double lengthOfSegmentInHours = segment.getLengthInHours();
                    expectedGenerationPerPlant += availablePlantCapacity * lengthOfSegmentInHours;
                }
                expectedGenerationPerTechnology += expectedGenerationPerPlant;
            }
            totalExpectedGeneration += expectedGenerationPerTechnology;

        }

        return totalExpectedGeneration;
    }

    private TreeMap<Integer, Double> calculateSimplePowerPlantInvestmentCashFlow(int depreciationTime, int buildingTime,
            double totalInvestment, double operatingProfit) {
        TreeMap<Integer, Double> investmentCashFlow = new TreeMap<Integer, Double>();
        double equalTotalDownPaymentInstallement = totalInvestment / buildingTime;
        for (int i = 0; i < buildingTime; i++) {
            investmentCashFlow.put(new Integer(i), equalTotalDownPaymentInstallement);
        }
        for (int i = buildingTime; i < depreciationTime + buildingTime; i++) {
            investmentCashFlow.put(new Integer(i), operatingProfit);
        }
        return investmentCashFlow;
    }

    private double npv(TreeMap<Integer, Double> netCashFlow, double wacc) {
        double npv = 0;
        for (Integer iterator : netCashFlow.keySet()) {
            npv += netCashFlow.get(iterator).doubleValue() / Math.pow(1 + wacc, iterator.intValue());
        }
        return npv;
    }

    /**
     * Calculates expected CO2 price based on a geometric trend estimation, of
     * the past years. The adjustmentForDetermineFuelMix needs to be set to 1,
     * if this is used in the determine fuel mix role.
     *
     * @param futureTimePoint
     *            Year the prediction is made for
     * @param yearsLookingBackForRegression
     *            How many years are used as input for the regression, incl. the
     *            current tick.
     * @return
     */
    protected HashMap<ElectricitySpotMarket, Double> determineExpectedCO2PriceInclTaxAndFundamentalForecast(
            long futureTimePoint, long yearsLookingBackForRegression, int adjustmentForDetermineFuelMix,
            long clearingTick) {
        HashMap<ElectricitySpotMarket, Double> co2Prices = new HashMap<ElectricitySpotMarket, Double>();
        CO2Auction co2Auction = reps.genericRepository.findFirst(CO2Auction.class);
        Iterable<ClearingPoint> cps = reps.clearingPointRepository.findAllClearingPointsForMarketAndTimeRange(
                co2Auction, clearingTick - yearsLookingBackForRegression + 1 - adjustmentForDetermineFuelMix,
                clearingTick - adjustmentForDetermineFuelMix, false);
        // Create regression object and calculate average
        SimpleRegression sr = new SimpleRegression();
        Government government = reps.template.findAll(Government.class).iterator().next();
        double lastPrice = 0;
        double averagePrice = 0;
        int i = 0;
        for (ClearingPoint clearingPoint : cps) {
            sr.addData(clearingPoint.getTime(), clearingPoint.getPrice());
            lastPrice = clearingPoint.getPrice();
            averagePrice += lastPrice;
            i++;
        }
        averagePrice = averagePrice / i;
        double expectedCO2Price;
        double expectedRegressionCO2Price;
        if (i > 1) {
            expectedRegressionCO2Price = sr.predict(futureTimePoint);
            expectedRegressionCO2Price = Math.max(0, expectedRegressionCO2Price);
            expectedRegressionCO2Price = Math.min(expectedRegressionCO2Price,
                    government.getCo2Penalty(futureTimePoint));
        } else {
            expectedRegressionCO2Price = lastPrice;
        }
        ClearingPoint expectedCO2ClearingPoint = reps.clearingPointRepository.findClearingPointForMarketAndTime(
                co2Auction,
                getCurrentTick()
                        + reps.genericRepository.findFirst(DecarbonizationModel.class).getCentralForecastingYear(),
                true);
        expectedCO2Price = (expectedCO2ClearingPoint == null) ? 0 : expectedCO2ClearingPoint.getPrice();
        expectedCO2Price = (expectedCO2Price + expectedRegressionCO2Price) / 2;
        for (ElectricitySpotMarket esm : reps.marketRepository.findAllElectricitySpotMarkets()) {
            double nationalCo2MinPriceinFutureTick = reps.nationalGovernmentRepository
                    .findNationalGovernmentByElectricitySpotMarket(esm).getMinNationalCo2PriceTrend()
                    .getValue(futureTimePoint);
            double co2PriceInCountry = 0d;
            if (expectedCO2Price > nationalCo2MinPriceinFutureTick) {
                co2PriceInCountry = expectedCO2Price;
            } else {
                co2PriceInCountry = nationalCo2MinPriceinFutureTick;
            }
            co2PriceInCountry += reps.genericRepository.findFirst(Government.class).getCO2Tax(futureTimePoint);
            co2Prices.put(esm, Double.valueOf(co2PriceInCountry));
        }
        return co2Prices;
    }

    public Map<Substance, Double> predictFuelPrices(EnergyProducer agent, long futureTimePoint) {
        // Fuel Prices
        Map<Substance, Double> expectedFuelPrices = new HashMap<Substance, Double>();
        for (Substance substance : reps.substanceRepository.findAllSubstancesTradedOnCommodityMarkets()) {
            // Find Clearing Points for the last 5 years (counting current year
            // as one of the last 5 years).
            Iterable<ClearingPoint> cps = reps.clearingPointRepository
                    .findAllClearingPointsForSubstanceTradedOnCommodityMarkesAndTimeRange(substance,
                            getCurrentTick() - (agent.getNumberOfYearsBacklookingForForecasting() - 1),
                            getCurrentTick(), false);
            // logger.warn("{}, {}",
            // getCurrentTick()-(agent.getNumberOfYearsBacklookingForForecasting()-1),
            // getCurrentTick());
            // Create regression object
            SimpleRegression gtr = new SimpleRegression();
            for (ClearingPoint clearingPoint : cps) {
                // logger.warn("CP {}: {} , in" + clearingPoint.getTime(),
                // substance.getName(), clearingPoint.getPrice());
                gtr.addData(clearingPoint.getTime(), clearingPoint.getPrice());
            }
            gtr.addData(getCurrentTick(), findLastKnownPriceForSubstance(substance, getCurrentTick()));
            expectedFuelPrices.put(substance, gtr.predict(futureTimePoint));
            // logger.warn("Forecast {}: {}, in Step " + futureTimePoint,
            // substance, expectedFuelPrices.get(substance));
        }
        return expectedFuelPrices;
    }

    /*
     * (non-Javadoc)
     * 
     * @see agentspring.role.Role#act(agentspring.agent.Agent)
     */
    @Override
    public void act(EnergyProducer arg0) {
        // TODO Auto-generated method stub

    }

}
