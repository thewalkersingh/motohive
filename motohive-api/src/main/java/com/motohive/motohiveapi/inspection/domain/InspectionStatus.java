package com.motohive.motohiveapi.inspection.domain;

import com.motohive.motohiveapi.common.state.StatefulStatus;

public enum InspectionStatus implements StatefulStatus {
	REQUESTED,
	ASSIGNED,
	INSPECTED,
	CERTIFIED,
	REJECTED,
	EXPIRED,
	CANCELLED
}