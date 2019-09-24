package com.allstars.config;
import com.allstars.Service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.AuthenticationEntryPoint;

@Configuration
@EnableWebSecurity
public class SecurityConfiguration extends WebSecurityConfigurerAdapter {

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

   @Autowired
   private UserService userService;

   @Autowired
   private AuthenticationEntryPoint basicAuthenticationEntryPoint;

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(userService).passwordEncoder(passwordEncoder);
    }


    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.csrf().disable();

        http.httpBasic().authenticationEntryPoint(basicAuthenticationEntryPoint).and()
                .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS);

        http.authorizeRequests().antMatchers(HttpMethod.POST).permitAll();
        http.authorizeRequests()
                .antMatchers(HttpMethod.GET,"v1/user/self").fullyAuthenticated()
                .anyRequest().permitAll();
    }

    //    @Autowired
//    private DataSource dataSource;

//    @Bean
//    @ConfigurationProperties("spring.datasource")
//    public DataSource dataSource(){
//        return DataSourceBuilder.create().build();
//    }
//
//    @Override
//    protected void configure(HttpSecurity http) throws Exception
//    {
//        http.authorizeRequests().anyRequest().permitAll().and().httpBasic();
//
//       // http.authorizeRequests().antMatchers(HttpMethod.POST).permitAll();
//    }
//
//
//
//    @Autowired
//    public void configureGlobal(AuthenticationManagerBuilder auth) throws Exception
//    {
//        auth.jdbcAuthentication().dataSource(dataSource)
//                .authoritiesByUsernameQuery("select username, role from user where username=?")
//                .usersByUsernameQuery("select username, password, 1 as enabled  from user where username=?");
//    }
//
//    @Bean
//    PasswordEncoder passwordEncoder() {
//        return new BCryptPasswordEncoder();
//    }
}
