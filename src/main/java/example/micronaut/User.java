package example.micronaut;

import io.micronaut.serde.annotation.Serdeable;

@Serdeable // <1>
public class User {

    private final String name;

    public User(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }
}
