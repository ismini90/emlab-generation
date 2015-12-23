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
package emlab.gen.role.tender;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import org.apache.commons.math.stat.regression.SimpleRegression;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.annotation.Transient;
import org.springframework.data.neo4j.support.Neo4jTemplate;

import agentspring.role.Role;
import agentspring.role.RoleComponent;
import emlab.gen.domain.agent.DecarbonizationModel;
import emlab.gen.domain.agent.EnergyProducer;
import emlab.gen.domain.agent.Government;
import emlab.gen.domain.gis.Zone;
import emlab.gen.domain.market.Bid;
import emlab.gen.domain.market.CO2Auction;
import emlab.gen.domain.market.ClearingPoint;
import emlab.gen.domain.market.electricity.ElectricitySpotMarket;
import emlab.gen.domain.policy.PowerGeneratingTechnologyTarget;
import emlab.gen.domain.policy.renewablesupport.RenewableSupportSchemeTender;
import emlab.gen.domain.policy.renewablesupport.TenderBid;
import emlab.gen.domain.technology.PowerGeneratingTechnology;
import emlab.gen.domain.technology.PowerGeneratingTechnologyNodeLimit;
import emlab.gen.domain.technology.PowerGridNode;
import emlab.gen.domain.technology.PowerPlant;
import emlab.gen.domain.technology.Substance;
import emlab.gen.domain.technology.SubstanceShareInFuelMix;
import emlab.gen.repository.Reps;
import emlab.gen.repository.StrategicReserveOperatorRepository;
import emlab.gen.role.AbstractEnergyProducerRole;

/**
 * @author kaveri
 *
 */

@RoleComponent
public class SubmitTenderBidRoleExpostRevenuePayment extends AbstractEnergyProducerRole<EnergyProducer>
        implements Role<EnergyProducer> {

    @Transient
    @Autowired
    Reps reps;

    @Transient
    @Autowired
    Neo4jTemplate template;

    @Transient
    @Autowired
    StrategicReserveOperatorRepository strategicReserveOperatorRepository;

    @Override
    public void act(EnergyProducer agent) {

        // logger.warn("Submit Tender Bid Role started for: " + agent);

        long futureTimePoint = getCurrentTick() + agent.getInvestmentFutureTimeHorizon();
        ElectricitySpotMarket market = agent.getInvestorMarket();

        // logger.warn("market is: " + market);

        Zone zone = agent.getInvestorMarket().getZone();
        RenewableSupportSchemeTender scheme = reps.renewableSupportSchemeTenderRepository
                .determineSupportSchemeForZone(zone);

        int noOfPlantsConsider = 0;

        for (PowerGeneratingTechnology technology : scheme.getPowerGeneratingTechnologiesEligible()) {

            // logger.warn("eligible are: " + technology);

            DecarbonizationModel model = reps.genericRepository.findAll(DecarbonizationModel.class).iterator().next();

            if (technology.isIntermittent() && model.isNoPrivateIntermittentRESInvestment())
                continue;

            Iterable<PowerGridNode> possibleInstallationNodes;

            /*
             * For dispatchable technologies just choose a random node. For
             * intermittent evaluate all possibilities.
             */
            if (technology.isIntermittent())
                possibleInstallationNodes = reps.powerGridNodeRepository.findAllPowerGridNodesByZone(market.getZone());
            else {
                possibleInstallationNodes = new LinkedList<PowerGridNode>();
                ((LinkedList<PowerGridNode>) possibleInstallationNodes).add(
                        reps.powerGridNodeRepository.findAllPowerGridNodesByZone(market.getZone()).iterator().next());
            }

            // logger.warn("technology is " + technology);

            // "technology is intermittent? " + technology.isIntermittent());
            // logger.warn("possibleInstallationNodes is: " +
            // possibleInstallationNodes);

            // logger.warn("Calculating for " + technology.getName() +
            // ", for Nodes: "
            // + possibleInstallationNodes.toString());

            for (PowerGridNode node : possibleInstallationNodes) {

                // logger.warn("node: " + node);

                PowerPlant plant = new PowerPlant();
                plant.specifyNotPersist(getCurrentTick(), agent, node, technology);

                noOfPlantsConsider++;
                // logger.warn("FOR no of plants considered " +
                // noOfPlantsConsider);

                // logger.warn("SubmitBid 168 - Agent " + agent + " looking at
                // technology at tick " + getCurrentTick()
                // + " in tech " + technology);

                // logger.warn(" agent is " + agent + " with technology " +
                // technology + " and plant " + plant
                // + " in node " + node);

                // if too much capacity of this technology in the pipeline (not
                // limited to the 5 years)
                double expectedInstalledCapacityOfTechnology = reps.powerPlantRepository
                        .calculateCapacityOfExpectedOperationalPowerPlantsInMarketAndTechnology(market, technology,
                                futureTimePoint);

                // technology target for the tender role is null
                PowerGeneratingTechnologyTarget technologyTarget = reps.powerGenerationTechnologyTargetRepository
                        .findOneByTechnologyAndMarket(technology, market);
                if (technologyTarget != null) {
                    double technologyTargetCapacity = technologyTarget.getTrend().getValue(futureTimePoint);
                    expectedInstalledCapacityOfTechnology = (technologyTargetCapacity > expectedInstalledCapacityOfTechnology)
                            ? technologyTargetCapacity : expectedInstalledCapacityOfTechnology;
                }
                double pgtNodeLimit = Double.MAX_VALUE;

                // logger.warn("pgtNodeLimit 1 is: " + pgtNodeLimit);

                PowerGeneratingTechnologyNodeLimit pgtLimit = reps.powerGeneratingTechnologyNodeLimitRepository
                        .findOneByTechnologyAndNode(technology, plant.getLocation());

                if (pgtLimit != null) {
                    pgtNodeLimit = pgtLimit.getUpperCapacityLimit(futureTimePoint);
                }

                // Calculate bid quantity. Number of plants to be bid - as many
                // as
                // the node permits

                double ratioNodeCapacity = pgtNodeLimit / plant.getActualNominalCapacity();

                // capacityTesting
                double numberOfPlants = (long) ratioNodeCapacity; // truncates
                // towards
                // lower
                // integer

                // if cash strapped, bid quantity according to fraction of cash,
                // which is translated to the number of plants
                // available.

                // If cash needed is larger than current cash of agent
                if (numberOfPlants * plant.getActualInvestedCapital()
                        * (1 - agent.getDebtRatioOfInvestments()) > agent.getDownpaymentFractionOfCash()
                                * agent.getCash()) {

                    double cashAvailableFraction = (agent.getDownpaymentFractionOfCash() * agent.getCash())
                            / (numberOfPlants * plant.getActualInvestedCapital()
                                    * (1 - agent.getDebtRatioOfInvestments()));

                    if (cashAvailableFraction < 0) {
                        cashAvailableFraction = 0;
                    }

                    numberOfPlants = cashAvailableFraction * numberOfPlants;

                    numberOfPlants = (long) numberOfPlants; // truncates
                    // towards
                    // lower
                    // integer

                }

                // ==== Expectations ===

                Map<Substance, Double> expectedFuelPrices = predictFuelPrices(agent, futureTimePoint);
                // logger.warn("expected fuel prices" + expectedFuelPrices);

                // CO2
                Map<ElectricitySpotMarket, Double> expectedCO2Price = determineExpectedCO2PriceInclTaxAndFundamentalForecast(
                        futureTimePoint, agent.getNumberOfYearsBacklookingForForecasting(), 0, getCurrentTick());
                // logger.warn("expected CO2 price" + expectedCO2Price);

                Map<Substance, Double> myFuelPrices = new HashMap<Substance, Double>();
                for (Substance fuel : technology.getFuels()) {
                    myFuelPrices.put(fuel, expectedFuelPrices.get(fuel));
                }
                Set<SubstanceShareInFuelMix> fuelMix = calculateFuelMix(plant, myFuelPrices,
                        expectedCO2Price.get(market));
                plant.setFuelMix(fuelMix);

                double expectedMarginalCost = determineExpectedMarginalCost(plant, expectedFuelPrices,
                        expectedCO2Price.get(market));
                // logger.warn("expected marginal cost in fip role for plant " +
                // plant + "is " + expectedMarginalCost);
                // insert here

                double annualMarginalCost = 0d;
                double totalGenerationinMWh = 0d;
                long tenderSchemeDuration = scheme.getSupportSchemeDuration();

                totalGenerationinMWh = plant.getAnnualFullLoadHours() * plant.getActualNominalCapacity();
                annualMarginalCost = totalGenerationinMWh * expectedMarginalCost;

                // logger.warn("for technology " +
                // plant.getTechnology().getName() + " total generation is "
                // + totalGenerationinMWh + " and running hours is " +
                // fullLoadHours);

                double fixedOMCost = calculateFixedOperatingCost(plant, getCurrentTick());
                double operatingCost = fixedOMCost + annualMarginalCost;

                // end insert here
                double wacc = (1 - agent.getDebtRatioOfInvestments()) * agent.getEquityInterestRate()
                        + agent.getDebtRatioOfInvestments() * agent.getLoanInterestRate();

                TreeMap<Integer, Double> discountedProjectCapitalOutflow = calculateSimplePowerPlantInvestmentCashFlow(
                        technology.getDepreciationTime(), (int) (plant.calculateActualLeadtime()),
                        plant.getActualInvestedCapital(), 0);

                // Creation of in cashflow during operation
                TreeMap<Integer, Double> discountedProjectCashOutflow = calculateSimplePowerPlantInvestmentCashFlow(
                        technology.getDepreciationTime(), (int) (plant.calculateActualLeadtime()), 1, -operatingCost);

                double discountedCapitalCosts = npv(discountedProjectCapitalOutflow, wacc);
                double discountedOpCost = npv(discountedProjectCashOutflow, wacc);
                double projectCost = discountedOpCost + discountedCapitalCosts;

                double bidPricePerMWh = 0d;

                // calculate discounted tender return factor term
                TreeMap<Integer, Double> discountedTenderReturnFactorSummingTerm = calculateSimplePowerPlantInvestmentCashFlow(
                        (int) tenderSchemeDuration, (int) plant.calculateActualLeadtime(), 0, 1);
                double discountedTenderReturnFactor = npv(discountedTenderReturnFactorSummingTerm, wacc);

                if (discountedTenderReturnFactor == 0) {
                    bidPricePerMWh = 0d;

                } else {

                    // calculate generation in MWh per year
                    bidPricePerMWh = -projectCost / (discountedTenderReturnFactor * totalGenerationinMWh);

                    int noOfPlantsBid = 0;
                    for (long i = 1; i <= numberOfPlants; i++) {

                        noOfPlantsBid++;
                        // logger.warn("FOR pp - no of plants Bid; " +
                        // noOfPlantsBid);

                        long start = getCurrentTick() + plant.calculateActualLeadtime()
                                + plant.calculateActualPermittime();
                        long finish = getCurrentTick() + plant.calculateActualLeadtime()
                                + plant.calculateActualPermittime() + tenderSchemeDuration;

                        TenderBid bid = new TenderBid();
                        bid.specifyAndPersist(totalGenerationinMWh, null, agent, zone, node, start, finish,
                                bidPricePerMWh, technology, getCurrentTick(), Bid.SUBMITTED, scheme);

                        // logger.warn("SubmitBid 454 - Agent " + agent + "
                        // ,generation " + totalGenerationinMWh
                        // + " ,plant " + plant + " ,zone " + zone + " ,node " +
                        // node + " ,start " + start
                        // + " ,finish " + finish + " ,bid price " +
                        // bidPricePerMWh + " ,tech " + technology
                        // + " ,current tick " + getCurrentTick() + " ,status "
                        // + Bid.SUBMITTED + " ,scheme "
                        // + scheme);

                    } // end for loop for tender bids

                } // end else calculate generation in MWh per year

                // } // end else calculate discounted tender return factor term
                plant.setDismantleTime(getCurrentTick());

            } // end for loop possible installation nodes

        } // end for (PowerGeneratingTechnology technology :
          // reps.genericRepository.findAll(PowerGeneratingTechnology.class))

    }

    // Create a powerplant investment and operation cash-flow in the form of a
    // map. If only investment, or operation costs should be considered set
    // totalInvestment or operatingProfit to 0
    private TreeMap<Integer, Double> calculateSimplePowerPlantInvestmentCashFlow(int depriacationTime, int buildingTime,
            double totalInvestment, double operatingProfit) {
        TreeMap<Integer, Double> investmentCashFlow = new TreeMap<Integer, Double>();
        double equalTotalDownPaymentInstallement = totalInvestment / buildingTime;
        for (int i = 0; i < buildingTime; i++) {
            investmentCashFlow.put(new Integer(i), -equalTotalDownPaymentInstallement);
        }
        for (int i = buildingTime; i < depriacationTime + buildingTime; i++) {
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
}
