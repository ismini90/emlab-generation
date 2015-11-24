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

import emlab.gen.domain.policy.renewablesupport.BiasFactor;
import emlab.gen.domain.policy.renewablesupport.RenewableSupportFipScheme;

/**
 * @author Kaveri3012
 *
 */
public interface RenewableSupportSchemeRepository extends GraphRepository<RenewableSupportFipScheme> {

    @Query(value = "g.v(scheme).in('BIASFACTOR_FOR_SUPPORTSCHEME').as('x').out('BIASFACTOR_FOR_NODE').filter{it.name==node}.back('x').out('BIASFACTOR_FOR_TECHNOLOGY').filter{it.name==technology}.back('x')", type = QueryType.Gremlin)
    public BiasFactor findBiasFactorGivenTechnologyNodeAndScheme(@Param("technology") String technologyName,
            @Param("node") String nodeName, @Param("scheme") RenewableSupportFipScheme scheme);

    @Query(value = "g.v(scheme).in('BIASFACTOR_FOR_SUPPORTSCHEME').as('x').out('BIASFACTOR_FOR_NODE').filter{it.name==node}.back('x').out('BIASFACTOR_FOR_TECHNOLOGY').filter{it.name==technology}.back('x')", type = QueryType.Gremlin)
    public BiasFactor findSchemeGivenZone(@Param("Zone") String technologyName, @Param("node") String nodeName,
            @Param("scheme") RenewableSupportFipScheme scheme);

}
