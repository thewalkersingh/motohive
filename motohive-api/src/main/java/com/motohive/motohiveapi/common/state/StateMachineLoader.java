package com.motohive.motohiveapi.common.state;

/**
 * Loads one machine definition from persistent storage.
 * Kept as an interface so tests can supply fakes;
 * production impl queries state_machine_definition + state_transition.
 */
public interface StateMachineLoader {
	
	<S extends Enum<S> & StatefulStatus, E extends Enum<E>>
	StateMachine<S, E> load(String name, Class<S> stateType, Class<E> eventType);
	
}