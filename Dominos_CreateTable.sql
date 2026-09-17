create database dominos;
use dominos; 

create table pizza_types (
        pizza_type_id varchar(50) not null,
        name varchar(100) not null,
        category varchar(50) not null,
        ingredients text,
        primary key (pizza_type_id)
);

create table pizzas (
        pizza_id varchar(50) not null,
        pizza_type_id varchar(50) not null,
        size varchar(10) not null,
        price decimal(10,2) not null,
        primary key (pizza_id),
        constraint fk_pizzas_pizza_type
             foreign key (pizza_type_id)
             references	pizza_types(pizza_type_id)
);


CREATE TABLE orders (
    order_id INT NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    
    PRIMARY KEY (order_id)
);


CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    
    PRIMARY KEY (order_details_id),
    
    CONSTRAINT fk_order_details_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
        
    CONSTRAINT fk_order_details_pizza
        FOREIGN KEY (pizza_id)
        REFERENCES pizzas(pizza_id)
);


select * from orders;
select * from order_details;
select * from pizza_types;
select * from pizzas;

SELECT COUNT(*) FROM pizza_types;
select count(*) from pizzas;
select count(*) from orders;
select count(*) from order_details;