package com.amazon.proserve.application.flight.service;

import com.amazon.proserve.application.flight.command.UpdateFlightSpecialHeaderCommand;
import com.amazon.proserve.application.flight.usecase.UpdateFlightSpecialHeaderUseCase;
import com.amazon.proserve.domain.flight.FlightSpecial;
import com.amazon.proserve.domain.flight.repository.FlightSpecialRepository;
import com.amazon.proserve.domain.flight.vo.Id;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UpdateFlightSpecialHeaderService implements UpdateFlightSpecialHeaderUseCase {
    private final FlightSpecialRepository repository;

    @Override
    public void updateFlightSpecialHeader(UpdateFlightSpecialHeaderCommand command) {
        Optional<FlightSpecial> optionalFlightSpecial = repository.findById(Id.of(Long.valueOf(command.getId())));
        if (optionalFlightSpecial.isPresent()) {
            FlightSpecial flightSpecial = optionalFlightSpecial.get();
            flightSpecial.updateFlightSpecialsHeader(command.getNewFlightSpecialsHeader());
            repository.save(flightSpecial);
        } else {
            // Handle the case where the FlightSpecial is not found
            throw new EntityNotFoundException("FlightSpecial not found for ID: " + command.getId());
        }
    }
}
