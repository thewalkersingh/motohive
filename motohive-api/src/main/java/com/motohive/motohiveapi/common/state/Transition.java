package com.motohive.motohiveapi.common.state;

import java.util.List;

/**
 * One row from state_transition, resolved to names for later lookup.
 * Instantiated by StateMachineRegistry when a machine is loaded.
 */
public record Transition<S extends Enum<S> & StatefulStatus, E extends Enum<E>>(
	E event,
	S fromState,
	S toState,
	String guardKey,
	List<String> effectKeys
) {

}