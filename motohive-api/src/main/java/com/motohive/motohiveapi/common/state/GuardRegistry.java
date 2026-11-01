package com.motohive.motohiveapi.common.state;

import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Resolves guard beans by name. The key is the Spring bean name,
 * which must match state_transition.guard_key.
 * Lazy-initialized once on first lookup to avoid eager bean creation.
 */
@Component
public class GuardRegistry {
	
	private final ApplicationContext ctx;
	private final Map<String, Guard<?, ?>> cache = new ConcurrentHashMap<>();
	
	public GuardRegistry(ApplicationContext ctx) {
		this.ctx = ctx;
	}
	
	@SuppressWarnings("unchecked")
	public <S extends Enum<S> & StatefulStatus, E extends Enum<E>>
	Guard<S, E> require(String key) {
		@SuppressWarnings("rawtypes")
		Guard<?, ?> g = cache.computeIfAbsent(key, k -> {
			try {
				return (Guard<?, ?>) ctx.getBean(k, Guard.class);
			} catch (Exception e) {
				throw new IllegalStateException(
					"Guard bean not found for key '" + key + "'", e);
			}
		});
		return (Guard<S, E>) g;
	}
	
}