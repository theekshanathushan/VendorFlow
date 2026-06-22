package com.vendorflow.controller;

import com.vendorflow.model.Order;
import com.vendorflow.model.OrderStatus;
import com.vendorflow.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class OrderController {

    private final OrderService orderService;

    @GetMapping
    public List<Order> getAllOrders() {
        return orderService.getAllOrders();
    }

    @PostMapping
    public Order createOrder(@RequestBody Order order) {
        return orderService.createOrder(order);
    }

    @PutMapping("/{id}/status")
    public Order updateOrderStatus(@PathVariable String id, @RequestBody Map<String, String> payload) {
        OrderStatus status = OrderStatus.valueOf(payload.get("status"));
        return orderService.updateOrderStatus(id, status);
    }
}
