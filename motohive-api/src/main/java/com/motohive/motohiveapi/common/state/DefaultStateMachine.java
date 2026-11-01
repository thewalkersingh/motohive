package com.motohive.motohiveapi.common.state;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/** Default immutable implementation backed by a pre-grouped map. */
final class DefaultStateMachine<S extends Enum<S> & StatefulStatus, E extends Enum<E>>
	implements StateMachine<S, E> {
	
	private final String name;
	private final Map<S, List<Transition<S, E>>> transitionsByFrom;
	
	DefaultStateMachine(String name, List<Transition<S, E>> transitions) {
		this.name = name;
		this.transitionsByFrom = transitions.stream()
														.collect(Collectors.groupingBy(
															Transition::fromState,
															Collectors.collectingAndThen(Collectors.toList(), List::copyOf)));
	}
	
	@Override
	public String name() {return name;}
	
	@Override
	public List<Transition<S, E>> transitionsFrom(S state) {
		return transitionsByFrom.getOrDefault(state, List.of());
	}
	
	@Override
	public Optional<Transition<S, E>> findTransition(S fromState, E event) {
		return transitionsFrom(fromState).stream()
													.filter(t -> t.event().equals(event))
													.findFirst();
	}
	
	@Override
	public List<E> availableEvents(S state) {
		return transitionsFrom(state).stream().map(Transition::event).toList();
	}
	
	@Override
	public boolean hasOutgoing(S state) {
		return !transitionsFrom(state).isEmpty();
	}
	
}