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
package emlab.gen.domain.policy.renewablesupport;

import org.neo4j.graphdb.Direction;
import org.springframework.data.neo4j.annotation.NodeEntity;
import org.springframework.data.neo4j.annotation.RelatedTo;

import emlab.gen.domain.agent.Regulator;
import emlab.gen.domain.technology.PowerGeneratingTechnology;
import emlab.gen.domain.technology.PowerGridNode;
import emlab.gen.trend.TimeSeriesCSVReader;
import emlab.gen.trend.TimeSeriesImpl;

/**
 * @author Kaveri3012
 *
 */
@NodeEntity
public class RenewableTarget {

    @RelatedTo(type = "SET_BY_REGULATOR", elementClass = Regulator.class, direction = Direction.INCOMING)
    Regulator regulator;

    @RelatedTo(type = "FOR_TECHNOLOGY", elementClass = PowerGeneratingTechnology.class, direction = Direction.OUTGOING)
    PowerGeneratingTechnology powerGeneratingTechnology;

    @RelatedTo(type = "AT_NODE", elementClass = PowerGridNode.class, direction = Direction.OUTGOING)
    PowerGridNode powerGridNode;

    @RelatedTo(type = "TARGET_TREND", elementClass = TimeSeriesImpl.class, direction = Direction.OUTGOING)
    TimeSeriesCSVReader yearlyRenewableTargetTimeSeries;

    private boolean targetTechnologySpecific;

    public Regulator getRegulator() {
        return regulator;
    }

    public void setRegulator(Regulator regulator) {
        this.regulator = regulator;
    }

    public PowerGeneratingTechnology getPowerGeneratingTechnology() {
        return powerGeneratingTechnology;
    }

    public void setPowerGeneratingTechnology(PowerGeneratingTechnology powerGeneratingTechnology) {
        this.powerGeneratingTechnology = powerGeneratingTechnology;
    }

    public PowerGridNode getPowerGridNode() {
        return powerGridNode;
    }

    public void setPowerGridNode(PowerGridNode powerGridNode) {
        this.powerGridNode = powerGridNode;
    }

    public TimeSeriesCSVReader getYearlyRenewableTargetTimeSeries() {
        return yearlyRenewableTargetTimeSeries;
    }

    public void setYearlyRenewableTargetTimeSeries(TimeSeriesCSVReader yearlyRenewableTargetTimeSeries) {
        this.yearlyRenewableTargetTimeSeries = yearlyRenewableTargetTimeSeries;
    }

    public boolean isTargetTechnologySpecific() {
        return targetTechnologySpecific;
    }

    public void setTargetTechnologySpecific(boolean isTargetTechnologySpecific) {
        this.targetTechnologySpecific = isTargetTechnologySpecific;
    }

}