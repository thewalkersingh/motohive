package com.motohive.motohiveapi.common.state;

/**
 * Named side-effect bean. Effects run in declared order after the state flip.
 * Implementations may write to the DB, send notifications, etc.
 * Bean name is what appears in state_transition.effect_keys.
 */
public interface SideEffect<S extends Enum<S> & StatefulStatus, E extends Enum<E>> {
	void execute(StatefulEntity<S> entity, E event, TransitionContext ctx);
}