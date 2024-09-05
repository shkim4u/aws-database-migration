package com.amazon.proserve.infrastructure.flight.persistence.jpa;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.amazon.proserve.domain.flight.FlightSpecial;

@Repository
public interface FlightSpecialJpaRepository extends JpaRepository<FlightSpecialJpaEntity, Long> {
    List<FlightSpecialJpaEntity> findAllByOrderByExpiryDateAsc();
}
