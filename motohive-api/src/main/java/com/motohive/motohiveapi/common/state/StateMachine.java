package com.motohive.motohiveapi.common.state;

import java.util.List;
import java.util.Optional;

/**
 * Loaded, immutable view of one state machine definition.
 * Produced by StateMachineRegistry; consumed by StateMachineService.
 */
public interface StateMachine<S extends Enum<S> & StatefulStatus, E extends Enum<E>> {
	
	String name();
	
	/** All legal transitions from the given state. */
	List<Transition<S, E>> transitionsFrom(S state);
	
	/** Find the transition for (fromState, event), if any. */
	Optional<Transition<S, E>> findTransition(S fromState, E event);
	
	/** All events available from the given state (for UI hints). */
	List<E> availableEvents(S state);
	
	/** True if any transition leaves the given state. */
	boolean hasOutgoing(S state);
	
}