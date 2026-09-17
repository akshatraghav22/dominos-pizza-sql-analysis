use dominos;

# 1. What is the total numbers of orders placed.
select count(order_id) as Total_orders from orders;

# 2. Calculate the Total revenue generated overall pizza sales
select round(sum(o.quantity * p.price),2) as Total_revenue from order_details o 
left join pizzas p 
on o.pizza_id = p.pizza_id;

# 3. Identify the hihest prices pizza

select  pt.name , p.price from pizzas p 
join pizza_types pt 
on p.pizza_type_id = pt.pizza_type_id 
order by p.price desc limit 1;

# 4. Identify the Most Common pizza Size ordered

select p.size, count(od.order_id) as TotaL_Order from pizzas p 
join order_details od 
on p.pizza_id = od.pizza_id 
group by p.size
order by TotaL_Order desc;


# 5. List The top 5 most ordered pizza names along with their quantity
# name, quantity

select pizza_types.name , sum(order_details.quantity) as total_quantity
from pizza_types
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id 
group by pizza_types.name 
order by total_quantity desc limit 5;


# 6. Determine the distribuation of orders by hour of the day.
-- hour | order_count

select hour(time) as hour , count(order_id) as order_count from orders
group by hour
order by hour ;


# 7. Dertmine the top 3 most ordered pizza  name based on total revenue

select pizza_types.name , round(sum(pizzas.price * order_details.quantity),2) as Total_revenue
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id =  order_details.pizza_id
group by pizza_types.name 
order by total_revenue desc limit 3;

# 8.Calculate the percentage Contribuation of each pizza_category to total revenue

with ppp as
(select pizza_types.category , round(sum(pizzas.price * order_details.quantity),2) as Total_revenue 
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id =  order_details.pizza_id
group by pizza_types.category
order by total_revenue desc)

select category,concat(round((total_revenue/ (select sum(total_revenue) from ppp))*100,2), "%") as Percentage
from ppp;

# 9. Find the Total quantity of each pizza category ordered.


select pizza_types.category , sum(order_details.quantity) as total_quantity
from pizza_types
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id 
group by pizza_types.category
order by total_quantity desc limit 5;


# 10.find out how many pizzas are their in each category 
select category, count(name) as Total_pizza from pizza_types group by category order by Total_pizza desc ; 

# 11. Find out Total revenue month wise.

select monthname(orders.date) as month , round(sum(pizzas.price * order_details.quantity),2) as Total_revenue 
from orders join order_details on orders.order_id = order_details.order_id
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by month;