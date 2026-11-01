package com.motohive.motohiveapi.common.state;

/** Outcome of a state transition attempt. */
public record TransitionResult<S extends Enum<S> & StatefulStatus>(
	boolean success,
	S fromState,
	S toState,
	String failureReason
) {
	
	public static <S extends Enum<S> & StatefulStatus> TransitionResult<S> ok(S from, S to) {
		return new TransitionResult<>(true, from, to, null);
	}
	
	public static <S extends Enum<S> & StatefulStatus> TransitionResult<S> fail(S from, String reason) {
		return new TransitionResult<>(false, from, null, reason);
	}
	
}