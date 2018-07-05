package hello;

import org.springframework.stereotype.Controller;
import org.springframework.boot.autoconfigure.*;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.boot.*;

@Controller
@EnableAutoConfiguration

public class HelloController {

    @RequestMapping("/")
    public @ResponseBody String greeting() {
        return "Hello World!";
    }
}