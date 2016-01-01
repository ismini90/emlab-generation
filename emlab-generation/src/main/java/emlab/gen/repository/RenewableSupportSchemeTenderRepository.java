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
package emlab.gen.repository;

import org.springframework.data.neo4j.annotation.Query;
import org.springframework.data.neo4j.annotation.QueryType;
import org.springframework.data.neo4j.repository.GraphRepository;
import org.springframework.data.repository.query.Param;

import emlab.gen.domain.agent.EnergyProducer;
import emlab.gen.domain.gis.Zone;
import emlab.gen.domain.policy.renewablesupport.RenewableSupportSchemeTender;
import emlab.gen.domain.technology.PowerGeneratingTechnology;

/**
 * @author Kaveri3012 rjjdejeu
 *
 */
public interface RenewableSupportSchemeTenderRepository extends GraphRepository<RenewableSupportSchemeTender> {

    // obtains the technologies eligible for the bid
    @Query(value = "g.idx('__types__')[[className:'emlab.gen.domain.policy.renewablesupport.RenewableSupportSchemeTender']].out('TECHNOLOGIES_ELIGIBLE_ARE')", type = QueryType.Gremlin)
    public Iterable<PowerGeneratingTechnology> findPowerGeneratingTechnologiesEligible();

    // obtains the support scheme duration for the energy producer
    @Query(value = "g.v(agent).out('INVESTOR_MARKET').out('ZONE').in('OF_ZONE').in('WITH_REGULATOR').supportSchemeDuration", type = QueryType.Gremlin)
    public long determineSupportSchemeDurationForEnergyProducer(@Param("agent") EnergyProducer agent);

    @Query(value = "g.v(agent).out('INVESTOR_MARKET').out('ZONE').in('OF_ZONE').in('WITH_REGULATOR')._()", type = QueryType.Gremlin)
    public Iterable<RenewableSupportSchemeTender> determineSpecificSupportSchemeForEnergyProducer(
            @Param("agent") EnergyProducer agent);

    @Query(value = "g.v(zone).filter{it.name == zone}.in('OF_ZONE').in('WITH_REGULATOR').out('TECHNOLOGIES_ELIGIBLE_ARE')", type = QueryType.Gremlin)
    public Iterable<RenewableSupportSchemeTender> findAllSpecificSupportSchemesByZone(@Param("zone") Zone zone);

    @Query(value = "g.v(zone).in('OF_ZONE').in('WITH_REGULATOR')", type = QueryType.Gremlin)
    public RenewableSupportSchemeTender determineSupportSchemeForZone(@Param("zone") Zone zone);

}
