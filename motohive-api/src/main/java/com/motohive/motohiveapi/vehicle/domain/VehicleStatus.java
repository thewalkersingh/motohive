package com.motohive.motohiveapi.vehicle.domain;

import com.motohive.motohiveapi.common.state.StatefulStatus;

public enum VehicleStatus implements StatefulStatus {
	DRAFT, REQUESTED, ASSIGNED, INSPECTED, CERTIFIED,
	REJECTED, EXPIRED, LISTED, RESERVED, SOLD
}