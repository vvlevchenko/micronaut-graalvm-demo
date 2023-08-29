package example.micronaut;

import jakarta.inject.Singleton;
import java.util.Arrays;
import java.util.List;
import java.util.Random;

@Singleton // <1>
public class UserService {

    private static final List<User> USERS = Arrays.asList(
            new User("Vasiliy"),
            new User("Sergey"),
            new User("Nicolay"),
            new User("Andrey"),
            new User("Yuriy"),
            new User("Konstantin"),
            new User("Olga"),
            new User("Irina")
    );

    public User randomUser() { // <2>
        return USERS.get(new Random().nextInt(USERS.size()));
    }
}
