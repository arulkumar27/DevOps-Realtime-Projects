package in.blacktunes.product.api;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;

public record Product(
        Long id,
        @NotBlank(message = "name is required") String name,
        @Positive(message = "price must be greater than zero") double price) {
}
