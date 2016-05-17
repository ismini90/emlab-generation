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

import emlab.gen.domain.agent.Regulator;
import emlab.gen.domain.policy.renewablesupport.RenewableSupportSchemeTender;
import emlab.gen.domain.policy.renewablesupport.RenewableTarget;
import emlab.gen.trend.TimeSeriesCSVReader;

/**
 * @author Kaveri3012
 *
 */
public interface RenewableTargetForTenderRepository extends GraphRepository<RenewableTarget> {

    @Query(value = "g.v(scheme).out('WITH_REGULATOR').out('SET_BY_REGULATOR').filter{it.__type__=='emlab.gen.domain.policy.renewablesupport.RenewableTarget'}.out('TARGET_TREND')", type = QueryType.Gremlin)
    public TimeSeriesCSVReader findRenewableTargetForTenderByScheme(
            @Param("scheme") RenewableSupportSchemeTender scheme);

    @Query(value = "g.v(regulator).out('SET_BY_REGULATOR').filter{it.targetTechnologySpecific == false}", type = QueryType.Gremlin)
    public RenewableTarget findTechnologyNeutralRenewableTargetForTenderByRegulator(
            @Param("regulator") Regulator regulator);

    @Query(value = "g.v(regulator).out('SET_BY_REGULATOR')}.filter{it.__type__=='emlab.gen.domain.policy.renewablesupport.RenewableTarget'}", type = QueryType.Gremlin)
    public RenewableTarget findRenewableTargetForTenderByRegulator(@Param("regulator") Regulator regulator);

    @Query(value = "g.v(scheme).out('WITH_REGULATOR').out('SET_BY_REGULATOR').filter{it.__type__=='emlab.gen.domain.policy.renewablesupport.RenewableTarget'}.as('x').out('FOR_TECHNOLOGY').filter{it.name==technologyName}.back('x').out('TARGET_TREND')", type = QueryType.Gremlin)
    public TimeSeriesCSVReader findTechnologySpecificRenewableTargetTimeSeriesForTenderByScheme(
            @Param("scheme") RenewableSupportSchemeTender scheme, @Param("technologyName") String technologyName);

    @Query(value = "g.v(regulator).out('SET_BY_REGULATOR').filter{it.__type__=='emlab.gen.domain.policy.renewablesupport.RenewableTarget'}.as('x').out('FOR_TECHNOLOGY').filter{it.name==technologyName}.back('x').filter{it.targetTechnologySpecific == true}.out('TARGET_TREND')", type = QueryType.Gremlin)
    public TimeSeriesCSVReader findTechnologySpecificRenewableTargetTimeSeriesForTenderByRegulator(
            @Param("regulator") Regulator regulator, @Param("technologyName") String technologyName);

    @Query(value = "g.v(regulator).out('SET_BY_REGULATOR').filter{it.__type__=='emlab.gen.domain.policy.renewablesupport.RenewableTarget'}.as('x').out('FOR_TECHNOLOGY').filter{it.name==technologyName}.back('x').filter{it.targetTechnologySpecific == true}", type = QueryType.Gremlin)
    public RenewableTarget findTechnologySpecificRenewableTargetForTenderByRegulator(
            @Param("regulator") Regulator regulator, @Param("technologyName") String technologyName);

    @Query(value = "g.v(regulator).out('SET_BY_REGULATOR').filter{it.__type__=='emlab.gen.domain.policy.renewablesupport.RenewableTarget'}.as('x').out('FOR_TECHNOLOGY').filter{it.name==technologyName}.back('x').out('AT_NODE').filter{it.name == nodeName}.back('x').filter{it.targetTechnologySpecific == true}.out('TARGET_TREND')", type = QueryType.Gremlin)
    public TimeSeriesCSVReader findTechnologyAndNodeSpecificRenewableTargetTimeSeriesForTenderByRegulator(
            @Param("regulator") Regulator regulator, @Param("technologyName") String technologyName,
            @Param("nodeName") String nodeName);

    // g.idx('__types__')[[className:'emlab.gen.domain.policy.renewablesupport.RenewableTargetForecast']]
    @Query(value = "g.v(regulator).out('SET_BY_REGULATOR').filter{it.__type__=='emlab.gen.domain.policy.renewablesupport.RenewablePotentialLimit'}.as('x').out('FOR_TECHNOLOGY').filter{it.name==technologyName}.back('x').filter{it.targetTechnologySpecific == true}.out('TARGET_TREND')", type = QueryType.Gremlin)
    public TimeSeriesCSVReader findTechnologySpecificRenewablePotentialLimitTimeSeriesByRegulator(
            @Param("regulator") Regulator regulator, @Param("technologyName") String technologyName);

}
