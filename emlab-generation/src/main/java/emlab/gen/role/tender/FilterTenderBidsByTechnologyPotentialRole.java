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

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.annotation.Transient;
import org.springframework.data.neo4j.support.Neo4jTemplate;
import org.springframework.transaction.annotation.Transactional;

import agentspring.role.AbstractRole;
import agentspring.role.Role;
import agentspring.role.RoleComponent;
import emlab.gen.domain.agent.EnergyProducer;
import emlab.gen.domain.market.Bid;
import emlab.gen.domain.market.electricity.ElectricitySpotMarket;
import emlab.gen.domain.policy.renewablesupport.RenewableSupportSchemeTender;
import emlab.gen.domain.policy.renewablesupport.TenderBid;
import emlab.gen.domain.technology.PowerGeneratingTechnology;
import emlab.gen.domain.technology.PowerGridNode;
import emlab.gen.domain.technology.PowerPlant;
import emlab.gen.repository.Reps;

/**
 * @author rjjdejeu
 */
@RoleComponent
public class FilterTenderBidsByTechnologyPotentialRole extends AbstractRole<RenewableSupportSchemeTender>
        implements Role<RenewableSupportSchemeTender> {
    Iterable<TenderBid> sortedTenderBidsbyPriceTechnologyAndNode;
    Iterable<TenderBid> sortedTenderBidsbyPriceTechnology;
    double technologyPotential;
    double technologyAndNodePotential;
    double expectedInstalledCapacityOfTechnologyInNode;
    double expectedGenerationFromTechnology;
    double limit;

    @Transient
    @Autowired
    Reps reps;

    @Transient
    @Autowired
    Neo4jTemplate template;

    @Override
    @Transactional
    public void act(RenewableSupportSchemeTender scheme) {
        ElectricitySpotMarket market = reps.marketRepository
                .findElectricitySpotMarketForZone(scheme.getRegulator().getZone());

        // 1. Loop through all the technologies in the tech neutral scheme.
        // 2. For each technology, find a list of sorted bids
        // 3. For each technology find potential (which for now is the same as
        // target).
        // 4. Go through each bid, sum all the bids cumulative until the
        // potential is met, this is done in the clear bid algorithm anyway!

        for (PowerGeneratingTechnology technology : scheme.getPowerGeneratingTechnologiesEligible()) {

            // POTENTIAL IN MWH ASSUMED TO BE THE SAME AS TARGET
            sortedTenderBidsbyPriceTechnology = reps.tenderBidRepository
                    .findAllSubmittedSortedTenderBidsbyTechnology(getCurrentTick(), scheme, technology.getName());

            technologyPotential = reps.renewableTargetForTenderRepository
                    .findTechnologySpecificRenewablePotentialLimitTimeSeriesByRegulator(scheme.getRegulator(),
                            technology.getName())
                    .getValue(getCurrentTick() + scheme.getFutureTenderOperationStartTime());

            logger.warn("verification: technology potential =" + technologyPotential);

            expectedInstalledCapacityOfTechnologyInNode = reps.powerPlantRepository
                    .calculateCapacityOfExpectedOperationalPowerPlantsInMarketAndTechnology(market, technology,
                            getCurrentTick() + scheme.getFutureTenderOperationStartTime());
            // create dummy power plant here

            PowerPlant plant = new PowerPlant();
            EnergyProducer producer = reps.energyProducerRepository.findAll().iterator().next();
            PowerGridNode node = reps.powerGridNodeRepository.findFirstPowerGridNodeByElectricitySpotMarket(market);
            plant.specifyNotPersist(getCurrentTick(), producer, node, technology);

            limit = technologyPotential
                    - (expectedInstalledCapacityOfTechnologyInNode * plant.getAnnualFullLoadHours());
            logger.warn("verification: expected generation ="
                    + expectedInstalledCapacityOfTechnologyInNode * plant.getAnnualFullLoadHours());

            logger.warn("Limit for technology " + technology.getName() + "is " + limit);

            double sumAcceptedBid = 0d;
            for (TenderBid currentBid : sortedTenderBidsbyPriceTechnology) {

                if ((sumAcceptedBid + currentBid.getAmount()) < limit) {
                    sumAcceptedBid += currentBid.getAmount();

                } else {
                    currentBid.setStatus(Bid.FAILED);
                }
            }
        }

        // if (cashAvailableForPlantDownpayment -
        // currentTenderBid.getCashNeededForPlantDownpayments() > 0) {
        // cashAvailableForPlantDownpayment =
        // cashAvailableForPlantDownpayment
        // - currentTenderBid.getCashNeededForPlantDownpayments();
        // else {

        // currentTenderBid.setStatus(Bid.NOT_SUBMITTED);
        // logger.warn("status of bid; " + currentTenderBid.getStatus()
        // + "is of technology"
        // + currentTenderBid.getTechnology());

    }

    private Iterable<TenderBid> getSortedTenderBids(RenewableSupportSchemeTender scheme,
            PowerGeneratingTechnology technology) {

        ElectricitySpotMarket market = reps.marketRepository
                .findElectricitySpotMarketForZone(scheme.getRegulator().getZone());

        for (PowerGridNode node : reps.powerGridNodeRepository
                .findAllPowerGridNodesByZone(scheme.getRegulator().getZone())) {

            // POTENTIAL IN MWH ASSUMED TO BE THE SAME AS TARGET

            // get
            technologyAndNodePotential = reps.renewableTargetForTenderRepository
                    .findTechnologyAndNodeSpecificRenewableTargetTimeSeriesForTenderByRegulator(scheme.getRegulator(),
                            technology.getName(), node.getName())
                    .getValue(getCurrentTick() + scheme.getFutureTenderOperationStartTime())
                    * scheme.getAnnualExpectedConsumption();
            expectedInstalledCapacityOfTechnologyInNode = reps.powerPlantRepository
                    .calculateCapacityOfExpectedOperationalPowerPlantsByNodeAndTechnology(node, technology,
                            getCurrentTick() + scheme.getFutureTenderOperationStartTime());
            PowerPlant plant = reps.powerPlantRepository.findOperationalPowerPlantsByMarketAndTechnology(market,
                    technology, getCurrentTick() + scheme.getFutureTenderOperationStartTime()).iterator().next();
            limit = technologyAndNodePotential
                    - (expectedInstalledCapacityOfTechnologyInNode * plant.getAnnualFullLoadHours());

            sortedTenderBidsbyPriceTechnologyAndNode = reps.tenderBidRepository
                    .findAllSubmittedSortedTenderBidsbyTechnologyAndNode(getCurrentTick(), scheme, technology.getName(),
                            node.getName());
        }
        return sortedTenderBidsbyPriceTechnologyAndNode;
        // currentTenderBid.persist();
    }
}