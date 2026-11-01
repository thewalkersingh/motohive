package com.motohive.motohiveapi.reservation.domain;

import com.motohive.motohiveapi.common.state.StatefulStatus;

public enum ReservationStatus implements StatefulStatus {
	HELD,
	REFUNDED,
	FORFEITED,
	CONVERTED,
	CANCELLED
}