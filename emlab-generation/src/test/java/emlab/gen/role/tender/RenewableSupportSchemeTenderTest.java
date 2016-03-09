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

import java.util.HashSet;
import java.util.Set;

import org.apache.log4j.Logger;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.transaction.annotation.Transactional;

import emlab.gen.domain.agent.EnergyProducer;
import emlab.gen.domain.agent.Regulator;
import emlab.gen.domain.gis.Zone;
import emlab.gen.domain.market.electricity.ElectricitySpotMarket;
import emlab.gen.domain.market.electricity.Segment;
import emlab.gen.domain.market.electricity.SegmentLoad;
import emlab.gen.domain.policy.renewablesupport.RenewableSupportSchemeTender;
import emlab.gen.domain.policy.renewablesupport.RenewableTarget;
import emlab.gen.domain.technology.PowerGeneratingTechnology;
import emlab.gen.domain.technology.PowerGridNode;
import emlab.gen.domain.technology.PowerPlant;
import emlab.gen.repository.Reps;
import emlab.gen.role.tender.CalculateRenewableTargetForTenderRole;
import emlab.gen.trend.GeometricTrend;
import emlab.gen.trend.TimeSeriesCSVReader;
import emlab.gen.trend.TriangularTrend;

/**
 * @author kaveri
 *
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration({ "/emlab-gen-test-context.xml" })
@Transactional
public class RenewableSupportSchemeTenderTest {

    Logger logger = Logger.getLogger(RenewableSupportSchemeTenderTest.class);

    RenewableSupportSchemeTender schemeA = new RenewableSupportSchemeTender();

    @Autowired
    Reps reps;

    @Autowired
    CalculateRenewableTargetForTenderRole calculateRenewableTargetForTenderRole;

    private static final double DELTA = 1e-6;

    @BeforeClass
    @Transactional
    public static void setUpBeforeClass() throws Exception {

        Zone zoneA = new Zone();
        zoneA.setName("ZoneA");
        zoneA.persist();

        PowerGeneratingTechnology wind = new PowerGeneratingTechnology();
        GeometricTrend windInvestmentTrend = new GeometricTrend();
        GeometricTrend windEfficiencyTrend = new GeometricTrend();
        windEfficiencyTrend.setStart(1);
        windEfficiencyTrend.setGrowthRate(0);
        windEfficiencyTrend.persist();
        windInvestmentTrend.setStart(10000);
        windInvestmentTrend.setGrowthRate(0.97);
        windInvestmentTrend.persist();
        GeometricTrend windFixedOperatingTrend = new GeometricTrend();
        windFixedOperatingTrend.setGrowthRate(0);
        windFixedOperatingTrend.setStart(0);
        windFixedOperatingTrend.persist();
        wind.setInvestmentCostTimeSeries(windInvestmentTrend);
        wind.setEfficiencyTimeSeries(windEfficiencyTrend);
        wind.setFixedOperatingCostTimeSeries(windFixedOperatingTrend);
        wind.setCapacity(200);
        wind.setExpectedLeadtime(2);
        wind.setExpectedPermittime(1);
        wind.setIntermittent(false);
        wind.setExpectedLifetime(20);
        wind.setPeakSegmentDependentAvailability(0.4);
        wind.setBaseSegmentDependentAvailability(0.1);
        wind.setName("Wind");
        wind.persist();

        PowerGeneratingTechnology pv = new PowerGeneratingTechnology();
        pv.setName("PV");
        GeometricTrend pvInvestmentTrend = new GeometricTrend();
        pvInvestmentTrend.setStart(12000);
        pvInvestmentTrend.setGrowthRate(1);
        pvInvestmentTrend.persist();
        GeometricTrend pvEfficiencyTrend = new GeometricTrend();
        pvEfficiencyTrend.setStart(1);
        pvEfficiencyTrend.setGrowthRate(0);
        pvEfficiencyTrend.persist();
        GeometricTrend pvFixedOperatingTrend = new GeometricTrend();
        pvFixedOperatingTrend.setStart(0);
        pvFixedOperatingTrend.setGrowthRate(0);
        pvFixedOperatingTrend.persist();
        pv.setCapacity(150);
        pv.setEfficiencyTimeSeries(pvEfficiencyTrend);
        pv.setInvestmentCostTimeSeries(pvInvestmentTrend);
        pv.setFixedOperatingCostTimeSeries(pvFixedOperatingTrend);
        pv.setFixedOperatingCostModifierAfterLifetime(0);
        pv.setExpectedLeadtime(1);
        pv.setExpectedPermittime(0);
        pv.setIntermittent(false);
        pv.setExpectedLifetime(15);
        pv.setPeakSegmentDependentAvailability(0.5);
        pv.setBaseSegmentDependentAvailability(0.1);
        pv.persist();

        Zone zoneB = new Zone();
        zoneB.setName("ZoneB");
        zoneB.persist();

        PowerGridNode powerGridNodeA = new PowerGridNode();
        powerGridNodeA.setZone(zoneA);
        powerGridNodeA.setCapacityMultiplicationFactor(1.0);
        powerGridNodeA.persist();
        PowerGridNode powerGridNodeB = new PowerGridNode();
        powerGridNodeB.setZone(zoneB);
        powerGridNodeB.setCapacityMultiplicationFactor(1.0);
        powerGridNodeB.persist();

        Segment S1 = new Segment();
        S1.setLengthInHours(20);
        S1.persist();

        Segment S2 = new Segment();
        S2.setLengthInHours(30);
        S2.persist();

        SegmentLoad SG1 = new SegmentLoad();
        SG1.setSegment(S2);
        SG1.setBaseLoad(2000);
        SG1.persist();

        SegmentLoad SG2 = new SegmentLoad();
        SG2.setSegment(S2);
        SG2.setBaseLoad(3000);

        // SegmentLoad SG3 = new SegmentLoad();
        // SG3.setSegment(S1);
        // SG3.setBaseLoad(3700);

        // SegmentLoad SG4 = new SegmentLoad();
        // SG4.setSegment(S1);
        // SG4.setBaseLoad(4000);

        SG2.persist();
        // SG3.persist();
        // SG4.persist();

        Set<SegmentLoad> segmentLoads1 = new HashSet<SegmentLoad>();
        segmentLoads1.add(SG1);
        segmentLoads1.add(SG2);

        TriangularTrend demandGrowthTrend = new TriangularTrend();
        demandGrowthTrend.setMax(2);
        demandGrowthTrend.setMin(1);
        demandGrowthTrend.setStart(1);
        demandGrowthTrend.setTop(1);
        demandGrowthTrend.persist();

        ElectricitySpotMarket marketA = new ElectricitySpotMarket();
        marketA.setName("marketA");
        marketA.setLoadDurationCurve(segmentLoads1);
        marketA.setDemandGrowthTrend(demandGrowthTrend);
        marketA.setZone(zoneA);
        marketA.persist();

        ElectricitySpotMarket marketB = new ElectricitySpotMarket();
        marketB.setName("marketB");
        marketB.setZone(zoneB);
        marketB.persist();

        EnergyProducer energyProducer1 = new EnergyProducer();
        EnergyProducer energyProducer2 = new EnergyProducer();

        PowerPlant windTurbineA1 = new PowerPlant();
        windTurbineA1.specifyAndPersist(-3, energyProducer1, powerGridNodeA, wind);

        PowerPlant windTurbineA2 = new PowerPlant();
        windTurbineA2.specifyAndPersist(-4, energyProducer2, powerGridNodeA, wind);

        PowerPlant windTurbineB1 = new PowerPlant();
        windTurbineB1.specifyAndPersist(5, energyProducer1, powerGridNodeB, wind);

        PowerPlant windTurbineB2 = new PowerPlant();
        windTurbineB2.specifyAndPersist(4, energyProducer2, powerGridNodeB, wind);

        PowerPlant pvA1 = new PowerPlant();
        pvA1.specifyAndPersist(-2, energyProducer1, powerGridNodeA, pv);

        PowerPlant pvA2 = new PowerPlant();
        pvA2.specifyAndPersist(-3, energyProducer2, powerGridNodeA, pv);

        PowerPlant pvB1 = new PowerPlant();
        pvB1.specifyAndPersist(5, energyProducer1, powerGridNodeB, pv);

        PowerPlant pvB2 = new PowerPlant();
        pvB2.specifyAndPersist(5, energyProducer2, powerGridNodeB, pv);

        Regulator regulatorA = new Regulator();
        regulatorA.setZone(zoneA);
        regulatorA.setNumberOfYearsLookingBackToForecastDemand(3);
        regulatorA.persist();

        Set<PowerGeneratingTechnology> setPV = new HashSet<PowerGeneratingTechnology>();
        setPV.add(pv);

        RenewableSupportSchemeTender schemeA = new RenewableSupportSchemeTender();
        schemeA.setRegulator(regulatorA);
        schemeA.setFutureTenderOperationStartTime(5);
        schemeA.setTechnologySpecificityEnabled(true);
        schemeA.setPowerGeneratingTechnologiesEligible(setPV);
        schemeA.persist();

        TimeSeriesCSVReader readerRenTarget = new TimeSeriesCSVReader();
        readerRenTarget.setDelimiter(",");
        readerRenTarget.setVariableName("nl_dummyTargetPV");
        readerRenTarget.setFilename("data/nodeAndTechSpecificPotentials.csv");
        readerRenTarget.persist();

        RenewableTarget targetPV = new RenewableTarget();
        targetPV.setRegulator(regulatorA);
        targetPV.setPowerGeneratingTechnology(pv);
        targetPV.setTargetTechnologySpecific(true);
        targetPV.setYearlyRenewableTargetTimeSeries(readerRenTarget);
        targetPV.persist();

        System.out.println("hello");

    }

    @Test
    public void calculateRenewableTargetForTenderRoleTest() {

        // calculateRenewableTargetForTenderRole.act(schemeA);
        double expectedGeneration = 0d;
        // assertEquals("Expected Generation", expectedGeneration,
        // schemeA.getAnnualExpectedConsumption(), DELTA);

    }

    @Test
    public void testFutureTimePoint() {

        // assertEquals("FutureTimePoint", 5,
        // schemeA.getFutureTenderOperationStartTime());

    }

}
