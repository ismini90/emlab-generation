package emlab.gen.role.tender;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import agentspring.role.AbstractRole;
import agentspring.role.Role;
import agentspring.role.RoleComponent;
import emlab.gen.domain.gis.Zone;
import emlab.gen.domain.market.electricity.ElectricitySpotMarket;
import emlab.gen.domain.market.electricity.Segment;
import emlab.gen.domain.market.electricity.SegmentLoad;
import emlab.gen.domain.policy.renewablesupport.RenewableSupportSchemeTender;
import emlab.gen.domain.technology.PowerGeneratingTechnology;
import emlab.gen.domain.technology.PowerPlant;
import emlab.gen.repository.Reps;
import emlab.gen.util.GeometricTrendRegression;

/**
 * @author Kaveri, rjjdejeu
 *
 */

@RoleComponent
public class CalculateRenewableTargetForTenderRole extends AbstractRole<RenewableSupportSchemeTender>
        implements Role<RenewableSupportSchemeTender> {

    @Autowired
    Reps reps;

    @Override
    @Transactional
    public void act(RenewableSupportSchemeTender scheme) {

        long futureStartingTenderTimePoint = getCurrentTick() + scheme.getFutureTenderOperationStartTime();
        double demandFactor;
        double targetFactor;
        Zone zone = scheme.getRegulator().getZone();

        // logger.warn("Calculate Renewable Target Role started of zone: " +
        // zone);

        ElectricitySpotMarket market = reps.marketRepository.findElectricitySpotMarketForZone(zone);

        // get demand factor
        demandFactor = predictDemandForElectricitySpotMarket(market,
                scheme.getRegulator().getNumberOfYearsLookingBackToForecastDemand(), futureStartingTenderTimePoint);

        // logger.warn("regulator name" + scheme.getRegulator().getName());
        // logger.warn("calculate technology name" +
        // scheme.getPowerGeneratingTechnologiesEligible().iterator().next().getName());

        if (scheme.isTechnologySpecificityEnabled()) {

            PowerGeneratingTechnology technology = scheme.getPowerGeneratingTechnologiesEligible().iterator().next();
            targetFactor = reps.renewableTargetForTenderRepository
                    .findTechnologySpecificRenewableTargetTimeSeriesForTenderByScheme(scheme, technology.getName())
                    .getValue(getCurrentTick() + scheme.getFutureTenderOperationStartTime());
        } else {
            targetFactor = reps.renewableTargetForTenderRepository
                    .findTechnologyNeutralRenewableTargetForTenderByRegulator(scheme.getRegulator())
                    .getYearlyRenewableTargetTimeSeries()
                    .getValue(getCurrentTick() + scheme.getFutureTenderOperationStartTime());

        }
        // get renewable energy target in factor (percent)

        // logger.warn("targetFactor; " + targetFactor);

        // get totalLoad in MWh
        double totalExpectedConsumption = 0d;

        for (SegmentLoad segmentLoad : market.getLoadDurationCurve()) {
            totalExpectedConsumption += segmentLoad.getBaseLoad() * demandFactor
                    * segmentLoad.getSegment().getLengthInHours();

        }

        scheme.setAnnualExpectedConsumption(totalExpectedConsumption);
        // logger.warn("totalExpectedConsumption; " + totalExpectedConsumption);

        // renewable target for tender operation start year in MWh is

        double renewableTargetInMwh = targetFactor * totalExpectedConsumption;
        // logger.warn("Policy based (total ) renewableTargetInMwh; " +
        // renewableTargetInMwh + "for scheme "
        // + scheme.getName());

        // calculate expected generation, and subtract that from annual
        // target.
        // will be ActualTarget
        double totalExpectedGeneration = 0d;
        double totalExpectedGenerationAvailable = 0d;
        double expectedGenerationPerTechnologyAvailable = 0d;
        double expectedGenerationPerPlantAvailable = 0d;

        long numberOfSegments = reps.segmentRepository.count();
        // logger.warn("number of segments; " + numberOfSegments);

        int noOfPlants = 0;

        for (PowerGeneratingTechnology technology : scheme.getPowerGeneratingTechnologiesEligible()) {
            expectedGenerationPerTechnologyAvailable = 0d;

            // logger.warn("For PGT - technology; " + technology);
            // logger.warn("For PGT - technology; " + technology);
            scheme.setCurrentTechnologyUnderConsideration(technology);

            for (PowerPlant plant : reps.powerPlantRepository.findOperationalPowerPlantsByMarketAndTechnology(market,
                    technology, futureStartingTenderTimePoint)) {
                expectedGenerationPerPlantAvailable = 0d;
                for (Segment segment : reps.segmentRepository.findAll()) {
                    double availablePlantCapacity = plant.getAvailableCapacity(futureStartingTenderTimePoint, segment,
                            numberOfSegments);

                    double lengthOfSegmentInHours = segment.getLengthInHours();
                    expectedGenerationPerPlantAvailable += availablePlantCapacity * lengthOfSegmentInHours;
                    // logger.warn("availablePlantCapacity" + numberOfSegments +
                    // "lengthOfSegmentInHours"
                    // + segment.getLengthInHours() +
                    // "expectedGenerationPerPlantAvailable"
                    // + expectedGenerationPerPlantAvailable);
                }
                expectedGenerationPerTechnologyAvailable += expectedGenerationPerPlantAvailable;
                // logger.warn("expectedGenerationPerTechnologyAvailable" +
                // expectedGenerationPerTechnologyAvailable);
            }
            totalExpectedGenerationAvailable += expectedGenerationPerTechnologyAvailable;
        }

        // logger.warn("totalExpectedGenerationAvailable; " +
        // totalExpectedGenerationAvailable);

        // logger.warn("renewabeTargetInMWh; " + renewableTargetInMwh +
        // "totalExpectedGeneration; "
        // + totalExpectedGeneration + " for year" +
        // futureStartingTenderTimePoint);
        // logger.warn("Last - totalExpectedGeneration; " +
        // totalExpectedGeneration);
        scheme.setYearlyTenderDemandTarget(renewableTargetInMwh);
        scheme.setExpectedRenewableGeneration(totalExpectedGenerationAvailable);

        renewableTargetInMwh = renewableTargetInMwh - totalExpectedGenerationAvailable;

        if (renewableTargetInMwh < 0) {
            renewableTargetInMwh = 0;
        }

        logger.warn("actualRenewableTargetInMwh; " + renewableTargetInMwh + " for year" + futureStartingTenderTimePoint
                + "for scheme " + scheme.getName());
        scheme.setAnnualRenewableTargetInMwh(renewableTargetInMwh);

    }

    public double predictDemandForElectricitySpotMarket(ElectricitySpotMarket market,
            long numberOfYearsBacklookingForForecasting, long futureTimePoint) {

        GeometricTrendRegression gtr = new GeometricTrendRegression();
        for (long time = getCurrentTick(); time > getCurrentTick() - numberOfYearsBacklookingForForecasting
                && time >= 0; time = time - 1) {
            gtr.addData(time, market.getDemandGrowthTrend().getValue(time));
        }
        double forecast = gtr.predict(futureTimePoint);
        if (Double.isNaN(forecast))
            forecast = market.getDemandGrowthTrend().getValue(getCurrentTick());
        return forecast;
    }
}