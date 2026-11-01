package com.motohive.motohiveapi.common.state;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Carries everything a Guard or SideEffect needs to make decisions and act.
 * Also carries the "before" snapshot for audit, populated by the engine
 * before mutating state.
 */
public final class TransitionContext {
	
	private final UUID actorUserId;
	private final String actorRole;
	private final Map<String, Object> attributes = new HashMap<>();
	private Object beforeSnapshot;
	private Object afterSnapshot;
	
	public TransitionContext(UUID actorUserId, String actorRole) {
		this.actorUserId = actorUserId;
		this.actorRole = actorRole;
	}
	
	public UUID actorUserId() { return actorUserId; }
	public String actorRole() { return actorRole; }
	
	public TransitionContext put(String key, Object value) {
		attributes.put(key, value);
		return this;
	}
	
	@SuppressWarnings("unchecked")
	public <T> T get(String key, Class<T> type) {
		Object v = attributes.get(key);
		if (v == null) return null;
		if (!type.isInstance(v)) {
			throw new IllegalStateException(
				"Attribute '" + key + "' is " + v.getClass().getName()
					+ ", not " + type.getName());
		}
		return (T) v;
	}
	
	public Object getRaw(String key) { return attributes.get(key); }
	public boolean has(String key) { return attributes.containsKey(key); }
	
	public Object beforeSnapshot() { return beforeSnapshot; }
	public void setBeforeSnapshot(Object s) { this.beforeSnapshot = s; }
	
	public Object afterSnapshot() { return afterSnapshot; }
	public void setAfterSnapshot(Object s) { this.afterSnapshot = s; }
}