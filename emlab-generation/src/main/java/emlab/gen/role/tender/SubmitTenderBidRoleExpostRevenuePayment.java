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

import java.util.LinkedList;
import java.util.Map;
import java.util.TreeMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.annotation.Transient;
import org.springframework.data.neo4j.support.Neo4jTemplate;

import agentspring.role.Role;
import agentspring.role.RoleComponent;
import emlab.gen.domain.agent.DecarbonizationModel;
import emlab.gen.domain.agent.EnergyProducer;
import emlab.gen.domain.gis.Zone;
import emlab.gen.domain.market.Bid;
import emlab.gen.domain.market.electricity.ElectricitySpotMarket;
import emlab.gen.domain.market.electricity.Segment;
import emlab.gen.domain.market.electricity.SegmentLoad;
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

        logger.warn("Submit Tender Bid Role started for: " + agent);

        long futureTimePoint = getCurrentTick() + agent.getInvestmentFutureTimeHorizon();
        ElectricitySpotMarket market = agent.getInvestorMarket();

        // logger.warn("market is: " + market);

        Zone zone = agent.getInvestorMarket().getZone();
        RenewableSupportSchemeTender scheme = reps.renewableSupportSchemeTenderRepository
                .determineSupportSchemeForZone(zone);

        int noOfPlantsConsider = 0;

        for (PowerGeneratingTechnology technology : scheme.getPowerGeneratingTechnologiesEligible()) {

            logger.warn("eligible are: " + technology);

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

                logger.warn("node: " + node);

                PowerPlant plant = new PowerPlant();
                plant.specifyNotPersist(getCurrentTick(), agent, node, technology);

                noOfPlantsConsider++;
                logger.warn("FOR no of plants considered " + noOfPlantsConsider);

                logger.warn("SubmitBid 168 - Agent " + agent + " looking at technology at tick " + getCurrentTick()
                        + " in tech " + technology);

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

                // insert here
                double mc = 0d;
                double annualMarginalCost = 0d;
                double totalGenerationinMWh = 0d;
                long numberOfSegments = reps.segmentRepository.count();
                double factor = 0d;
                double fullLoadHours = 0d;
                long tenderSchemeDuration = scheme.getSupportSchemeDuration();

                mc = calculateMarginalCostExclCO2MarketCost(plant, getCurrentTick());

                for (SegmentLoad segmentLoad : market.getLoadDurationCurve()) {
                    Segment segment = segmentLoad.getSegment();

                    if (technology.isIntermittent()) {
                        factor = plant.getIntermittentTechnologyNodeLoadFactor().getLoadFactorForSegment(segment);
                    } else {
                        double segmentID = segment.getSegmentID();
                        double min = technology.getPeakSegmentDependentAvailability();
                        double max = technology.getBaseSegmentDependentAvailability();
                        double segmentPortion = (numberOfSegments - segmentID) / (numberOfSegments - 1); // start
                        // counting
                        // at
                        // 1.

                        double range = max - min;
                        factor = max - segmentPortion * range;

                    }

                    fullLoadHours += factor * segment.getLengthInHours();

                }

                totalGenerationinMWh = fullLoadHours * plant.getActualNominalCapacity();
                annualMarginalCost = totalGenerationinMWh * mc;

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
                        technology.getDepreciationTime(),
                        (int) (plant.calculateActualLeadtime() + plant.calculateActualPermittime()),
                        plant.getActualInvestedCapital(), 0);

                // Creation of in cashflow during operation
                TreeMap<Integer, Double> discountedProjectCashOutflow = calculateSimplePowerPlantInvestmentCashFlow(
                        technology.getDepreciationTime(),
                        (int) (plant.calculateActualLeadtime() + plant.calculateActualPermittime()), operatingCost, 0);

                double discountedCapitalCosts = npv(discountedProjectCapitalOutflow, wacc);
                double discountedOpCost = npv(discountedProjectCashOutflow, wacc);
                double projectValue = discountedOpCost + discountedCapitalCosts;

                double bidPricePerMWh = 0d;

                if (projectValue >= 0 || totalGenerationinMWh == 0) {
                    bidPricePerMWh = 0d;

                } else {

                    // calculate discounted tender return factor term
                    TreeMap<Integer, Double> discountedTenderReturnFactorSummingTerm = calculateSimplePowerPlantInvestmentCashFlow(
                            (int) tenderSchemeDuration,
                            (int) (plant.calculateActualLeadtime() + plant.calculateActualPermittime()), 0, 1);
                    double discountedTenderReturnFactor = npv(discountedTenderReturnFactorSummingTerm, wacc);

                    if (discountedTenderReturnFactor == 0) {
                        bidPricePerMWh = 0d;

                    } else {

                        // calculate generation in MWh per year
                        bidPricePerMWh = -projectValue / (discountedTenderReturnFactor * totalGenerationinMWh);

                        int noOfPlantsBid = 0;
                        for (long i = 1; i <= numberOfPlants; i++) {

                            noOfPlantsBid++;
                            logger.warn("FOR pp - no of plants Bid; " + noOfPlantsBid);

                            long start = getCurrentTick() + plant.calculateActualLeadtime()
                                    + plant.calculateActualPermittime();
                            long finish = getCurrentTick() + plant.calculateActualLeadtime()
                                    + plant.calculateActualPermittime() + tenderSchemeDuration;

                            TenderBid bid = new TenderBid();
                            bid.specifyAndPersist(totalGenerationinMWh, null, agent, zone, node, start, finish,
                                    bidPricePerMWh, technology, getCurrentTick(), Bid.SUBMITTED, scheme);

                            logger.warn("SubmitBid 454 - Agent " + agent + " ,generation " + totalGenerationinMWh
                                    + " ,plant " + plant + " ,zone " + zone + " ,node " + node + " ,start " + start
                                    + " ,finish " + finish + " ,bid price " + bidPricePerMWh + " ,tech " + technology
                                    + " ,current tick " + getCurrentTick() + " ,status " + Bid.SUBMITTED + " ,scheme "
                                    + scheme);

                        } // end for loop for tender bids

                    } // end else calculate generation in MWh per year

                } // end else calculate discounted tender return factor term
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
}
