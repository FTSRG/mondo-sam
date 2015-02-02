package eu.mondo.sam.core.phases;

import java.util.concurrent.TimeUnit;

import eu.mondo.sam.core.cases.BenchmarkCase;
import eu.mondo.sam.core.cases.CaseBuilder;
import eu.mondo.sam.core.phases.BenchmarkPhase;
import eu.mondo.sam.core.results.BenchmarkResult;
import eu.mondo.sam.core.results.PhaseResult;
import eu.mondo.sam.core.metric.BenchmarkMetric;

import com.google.common.base.Stopwatch;

public class BenchmarkEngine {

	private BenchmarkResult benchmarkResult;
	private CaseBuilder caseBuilder;
	
	public BenchmarkEngine(CaseBuilder caseBuilder){
		this.caseBuilder = caseBuilder;
	}
	
	public void runBenchmark() throws CloneNotSupportedException{
		benchmarkResult = new BenchmarkResult();
		BenchmarkCase benchmarkCase = caseBuilder.getCase();
		benchmarkResult.setBenchmarkCase(benchmarkCase);
		
		for(BenchmarkPhaseGroup group : benchmarkCase.getGroups()){
			for(int i=0; i<group.getLoop(); i++){
				for(BenchmarkPhase phase : group.getPhases()){
					PhaseResult result = new PhaseResult();
					result.setPhaseName(phase.getPhaseName());
					BenchmarkMetric timer = new BenchmarkMetric("Time");
					
					Stopwatch stopwatch = Stopwatch.createStarted();
					
					try {
						phase.execute();
					} catch (PhaseInterruptedException e) {
						continue;
					}
					finally{
						stopwatch.stop();
						long time = stopwatch.elapsed(TimeUnit.NANOSECONDS);
						timer.setValue(time);
						for (BenchmarkMetric m : phase.getMetrics()){
							if (m.isMeasured())
								result.addMetrics(m.clone());
						}
						if (result.isMeasuredPhase() == true)
							result.addMetrics(timer);
						
					}
					benchmarkResult.storeResults(result);
				}
			}
		}
		benchmarkResult.publishResults();
	}

}
