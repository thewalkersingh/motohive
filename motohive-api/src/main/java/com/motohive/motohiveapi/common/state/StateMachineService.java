package com.motohive.motohiveapi.common.state;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class StateMachineService {
	
	private final StateMachineRegistry machines;
	private final GuardRegistry guards;
	private final SideEffectRegistry effects;
	
	public StateMachineService(StateMachineRegistry machines,
		GuardRegistry guards,
		SideEffectRegistry effects) {
		this.machines = machines;
		this.guards = guards;
		this.effects = effects;
	}
	
	@Transactional
	public <S extends Enum<S> & StatefulStatus, E extends Enum<E>>
	TransitionResult<S> fire(StatefulEntity<S> entity,
		E event,
		TransitionContext ctx,
		String machineName,
		Class<S> stateType,
		Class<E> eventType) {
		
		StateMachine<S, E> machine = machines.get(machineName, stateType, eventType);
		S from = entity.getStatus();
		
		Transition<S, E> transition = machine.findTransition(from, event)
														 .orElse(null);
		
		if (transition == null) {
			return TransitionResult.fail(from,
				"No transition for event " + event + " from state " + from);
		}
		
		// 1. Guard check
		if (transition.guardKey() != null) {
			Guard<S, E> guard = guards.require(transition.guardKey());
			if (!guard.evaluate(entity, event, ctx)) {
				return TransitionResult.fail(from,
					"Guard '" + transition.guardKey() + "' rejected transition");
			}
		}
		
		// 2. Capture before-snapshot (used by audit)
		ctx.setBeforeSnapshot(snapshotOf(entity));
		
		// 3. Flip state
		entity.setStatus(transition.toState());
		
		// 4. Capture after-snapshot
		ctx.setAfterSnapshot(snapshotOf(entity));
		
		// 5. Run effects in declared order
		List<String> keys = transition.effectKeys();
		for (String key : keys) {
			SideEffect<S, E> effect = effects.require(key);
			effect.execute(entity, event, ctx);
		}
		
		return TransitionResult.ok(from, transition.toState());
	}
	
	/**
	 * Placeholder — real snapshotting is JSON serialization of the entity's
	 * audited fields. Implemented in Part 3 once the audit side effect exists.
	 */
	protected Object snapshotOf(StatefulEntity<?> entity) {
		return entity;
	}
	
}