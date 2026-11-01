package com.motohive.motohiveapi.common.state;

import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/**
 * In-memory cache of loaded state machines, populated lazily.
 * Each machine is loaded once from state_machine_definition / state_transition
 * via StateMachineLoader, then reused. Admin updates call invalidate(name).
 */
@Component
public class StateMachineRegistry {
	
	private final StateMachineLoader loader;
	private final Map<String, StateMachine<?, ?>> cache = new ConcurrentHashMap<>();
	
	public StateMachineRegistry(StateMachineLoader loader) {
		this.loader = loader;
	}
	
	@SuppressWarnings("unchecked")
	public <S extends Enum<S> & StatefulStatus, E extends Enum<E>>
	StateMachine<S, E> get(String name, Class<S> stateType, Class<E> eventType) {
		StateMachine<?, ?> cached = cache.get(name);
		if (cached != null) {
			return (StateMachine<S, E>) cached;
		}
		StateMachine<S, E> loaded = loader.load(name, stateType, eventType);
		StateMachine<?, ?> existing = cache.putIfAbsent(name, loaded);
		return (StateMachine<S, E>) (existing != null ? existing : loaded);
	}
	
	public void invalidate(String name) {
		cache.remove(name);
	}
	
	public Optional<StateMachine<?, ?>> peek(String name) {
		return Optional.ofNullable(cache.get(name));
	}
	
	public List<String> cachedNames() {
		return List.copyOf(cache.keySet());
	}
	
}