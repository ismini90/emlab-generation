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
import emlab.gen.domain.market.Bid;
import emlab.gen.domain.policy.renewablesupport.RenewableSupportSchemeTender;
import emlab.gen.domain.policy.renewablesupport.TenderBid;
import emlab.gen.domain.technology.PowerGeneratingTechnology;
import emlab.gen.repository.Reps;

/**
 * @author rjjdejeu
 */
@RoleComponent
public class FilterTenderBidsByTechnologyPotentialRole extends AbstractRole<RenewableSupportSchemeTender>
        implements Role<RenewableSupportSchemeTender> {

    @Transient
    @Autowired
    Reps reps;

    @Transient
    @Autowired
    Neo4jTemplate template;

    @Override
    @Transactional
    public void act(RenewableSupportSchemeTender scheme) {

        Iterable<TenderBid> sortedTenderBidsbyPriceAndTechnology = null;
        double technologyPotential;

        // 1. Loop through all the technologies in the tech neutral scheme.
        // 2. For each technology, find a list of sorted bids
        // 3. For each technology find potential (which for now is the same as
        // target).
        // 4. Go through each bid, sum all the bids cumulative until the
        // potential is met, this is done in the clear bid algorithm anyway!

        for (PowerGeneratingTechnology technology : scheme.getPowerGeneratingTechnologiesEligible()) {
            sortedTenderBidsbyPriceAndTechnology = reps.tenderBidRepository
                    .findAllSubmittedSortedTenderBidsbyTechnology(getCurrentTick(), scheme, technology.getName());

            // POTENTIAL IN MWH ASSUMED TO BE THE SAME AS TARGET
            technologyPotential = reps.renewableTargetForTenderRepository
                    .findTechnologySpecificRenewableTargetTimeSeriesForTenderByRegulator(scheme.getRegulator(),
                            technology.getName())
                    .getValue(getCurrentTick() + scheme.getFutureTenderOperationStartTime())
                    * scheme.getAnnualExpectedConsumption();

            logger.warn("technology potential" + technologyPotential);

            double sumAcceptedBid = 0d;
            for (TenderBid currentBid : sortedTenderBidsbyPriceAndTechnology) {

                if ((sumAcceptedBid + currentBid.getAmount()) < technologyPotential) {
                    sumAcceptedBid += currentBid.getAmount();

                } else {
                    currentBid.setStatus(Bid.FAILED);
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

        }

    }

    // currentTenderBid.persist();
    // }
}
