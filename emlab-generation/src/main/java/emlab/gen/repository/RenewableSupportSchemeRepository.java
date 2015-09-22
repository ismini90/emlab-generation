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
import emlab.gen.domain.technology.PowerGeneratingTechnology;
import emlab.gen.domain.technology.PowerGridNode;

/**
 * @author Kaveri3012
 *
 */
public interface RenewableSupportSchemeRepository extends GraphRepository<RenewableSupportFipScheme> {

    @Query(value = "g.v(scheme).in('BIASFACTOR_FOR_SUPPORTSCHEME').as('x').out('BIASFACTOR_FOR_NODE').propertyFilter('name', FilterPipe.Filter.EQUAL, node.name).back('x').out('BIASFACTOR_FOR_TECHNOLOGY').propertyFilter('name', FilterPipe.Filter.EQUAL, technology.name).back('x')", type = QueryType.Gremlin)
    public BiasFactor findBiasFactorGivenTechnologyNodeAndScheme(
            @Param("technology") PowerGeneratingTechnology technology, @Param("node") PowerGridNode node,
            @Param("scheme") RenewableSupportFipScheme scheme);

}
