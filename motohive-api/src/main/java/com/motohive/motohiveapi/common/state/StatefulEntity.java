package com.motohive.motohiveapi.common.state;

/**
 * Any entity whose status can be driven by a StateMachine.
 * The entity exposes its state generically; the concrete enum type is
 * established at the call site (StateMachineService<T, S, E>).
 */
public interface StatefulEntity<S extends Enum<S> & StatefulStatus> {
	S getStatus();
	void setStatus(S status);
}