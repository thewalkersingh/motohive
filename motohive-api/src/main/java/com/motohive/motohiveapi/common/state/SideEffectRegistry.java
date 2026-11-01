package com.motohive.motohiveapi.common.state;

import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class SideEffectRegistry {
	
	private final ApplicationContext ctx;
	private final Map<String, SideEffect<?, ?>> cache = new ConcurrentHashMap<>();
	
	public SideEffectRegistry(ApplicationContext ctx) {
		this.ctx = ctx;
	}
	
	@SuppressWarnings("unchecked")
	public <S extends Enum<S> & StatefulStatus, E extends Enum<E>>
	SideEffect<S, E> require(String key) {
		@SuppressWarnings("rawtypes")
		SideEffect<?, ?> effect = cache.computeIfAbsent(key, k -> {
			try {
				return (SideEffect<?, ?>) ctx.getBean(k, SideEffect.class);
			} catch (Exception e) {
				throw new IllegalStateException(
					"SideEffect bean not found for key '" + key + "'", e);
			}
		});
		return (SideEffect<S, E>) effect;
	}
	
}