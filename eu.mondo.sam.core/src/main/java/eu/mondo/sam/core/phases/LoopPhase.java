package eu.mondo.sam.core.phases;

import eu.mondo.sam.core.phases.iterators.LoopPhaseIterator;
import eu.mondo.sam.core.phases.iterators.PhaseIterator;

public abstract class LoopPhase extends ConditionalPhase{

	protected LoopPhaseIterator iterator;
	
	public LoopPhase(){
		iterator = new LoopPhaseIterator(this);
	}
	
	@Override
	public PhaseIterator getIterator() {
		return iterator;
	}

}