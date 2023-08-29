package example.micronaut;

import io.micronaut.http.annotation.Controller;
import io.micronaut.http.annotation.Get;

@Controller("/users") // <1>
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) { // <2>
        this.userService = userService;
    }

    @Get("/random") // <3>
    public User randomUser() { // <4>
        User user = userService.randomUser();
        return user;
    }
}
