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

import agentspring.role.Role;
import agentspring.role.RoleComponent;
import emlab.gen.domain.agent.EnergyProducer;
import emlab.gen.domain.gis.Zone;
import emlab.gen.domain.market.Bid;
import emlab.gen.domain.policy.renewablesupport.TenderBid;
import emlab.gen.repository.Reps;
import emlab.gen.role.AbstractEnergyProducerRole;

/**
 * @author rjjdejeu
 */
@RoleComponent
public class FilterTenderBidsWithSufficientCashForDownpaymentRole extends AbstractEnergyProducerRole<EnergyProducer>
        implements Role<EnergyProducer> {

    @Transient
    @Autowired
    Reps reps;

    @Transient
    @Autowired
    Neo4jTemplate template;

    @Override
    @Transactional
    public void act(EnergyProducer agent) {

        logger.warn("Filter Tender Bids With Sufficient Cashflow for Downpayment Role started for " + agent);

        Zone zone = agent.getInvestorMarket().getZone();
        String agentName = agent.getName();

        // Initialize a sorted list for tender bids
        Iterable<TenderBid> sortedTenderBidsbyPrice = null;
        sortedTenderBidsbyPrice = reps.tenderBidRepository.findAllSortedTenderBidsbyTimeAndInvestor(getCurrentTick(),
                agentName, zone);

        double cashAvailableForPlantDownpayment = agent.getDownpaymentFractionOfCash() * agent.getCash();
        // logger.warn("cashAvailableForPlantDownpayment; " +
        // cashAvailableForPlantDownpayment);

        for (TenderBid currentTenderBid : sortedTenderBidsbyPrice) {

            // logger.warn("currentTenderBid; " + currentTenderBid);

            if (cashAvailableForPlantDownpayment > 0) {
                cashAvailableForPlantDownpayment = cashAvailableForPlantDownpayment
                        - currentTenderBid.getCashNeededForPlantDownpayments();

                // logger.warn("cashAvailableForPlantDownpayment; " +
                // cashAvailableForPlantDownpayment);
                // logger.warn("currentTenderBid.getCashNeededForPlantDownpayments; "
                // + currentTenderBid.getCashNeededForPlantDownpayments());
                // logger.warn("status of bid; " +
                // currentTenderBid.getStatus());
            }

            else {
                currentTenderBid.setStatus(Bid.NOT_SUBMITTED);

                // logger.warn("status of bid; " +
                // currentTenderBid.getStatus());

            }

            currentTenderBid.persist();
        }
    }
}
