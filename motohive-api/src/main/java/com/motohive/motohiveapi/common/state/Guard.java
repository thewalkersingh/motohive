package com.motohive.motohiveapi.common.state;

/**
 * Named guard bean. Guards decide whether a transition is allowed.
 * Implementations must be stateless and thread-safe.
 * Bean name is the guard_key in state_transition.
 */
public interface Guard<S extends Enum<S> & StatefulStatus, E extends Enum<E>> {
	
	boolean evaluate(StatefulEntity<S> entity, E event, TransitionContext ctx);
	
}