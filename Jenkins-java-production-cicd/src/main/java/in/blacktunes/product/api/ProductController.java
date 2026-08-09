package in.blacktunes.product.api;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicLong;

@RestController
@RequestMapping("/api")
public class ProductController {
    private final List<Product> products = new CopyOnWriteArrayList<>();
    private final AtomicLong sequence = new AtomicLong();

    @Value("${app.version:local}")
    private String version;

    public ProductController() {
        products.add(new Product(sequence.incrementAndGet(), "Cloud Course", 1999.0));
        products.add(new Product(sequence.incrementAndGet(), "DevOps Course", 2499.0));
    }

    @GetMapping("/products")
    public List<Product> products() {
        return products;
    }

    @PostMapping("/products")
    @ResponseStatus(HttpStatus.CREATED)
    public Product create(@Valid @RequestBody Product request) {
        Product created = new Product(sequence.incrementAndGet(), request.name(), request.price());
        products.add(created);
        return created;
    }

    @GetMapping("/info")
    public Map<String, Object> info() {
        return Map.of(
                "application", "product-service",
                "version", version,
                "timestamp", Instant.now().toString());
    }
}
