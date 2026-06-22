package com.vendorflow.service;

import com.vendorflow.model.Order;
import com.vendorflow.model.OrderItem;
import com.vendorflow.model.OrderStatus;
import com.vendorflow.model.Product;
import com.vendorflow.repository.OrderRepository;
import com.vendorflow.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;

    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }
    
    public Order createOrder(Order order) {
        // Validate stock before creating
        for (OrderItem item : order.getItems()) {
            Product product = productRepository.findById(item.getProductId())
                .orElseThrow(() -> new RuntimeException("Product not found: " + item.getProductId()));
            
            if (product.getStockCount() < item.getQuantity()) {
                throw new RuntimeException("Insufficient stock for product: " + product.getName() + ". Only " + product.getStockCount() + " left.");
            }
            item.setProductName(product.getName());
            item.setUnitPrice(product.getPrice());
        }
        
        order.setStatus(OrderStatus.NEW);
        order.setCreatedAt(LocalDateTime.now());
        order.setUpdatedAt(LocalDateTime.now());
        return orderRepository.save(order);
    }

    @Transactional
    public Order updateOrderStatus(String id, OrderStatus newStatus) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        // Tap-to-Deduct logic: If status changes to PAID, deduct stock.
        if (newStatus == OrderStatus.PAID && order.getStatus() != OrderStatus.PAID) {
            for (OrderItem item : order.getItems()) {
                Product product = productRepository.findById(item.getProductId())
                    .orElseThrow(() -> new RuntimeException("Product not found"));
                
                int newStock = product.getStockCount() - item.getQuantity();
                if (newStock < 0) {
                    throw new RuntimeException("Cannot mark as paid. Insufficient stock for " + product.getName());
                }
                
                product.setStockCount(newStock);
                productRepository.save(product);
                
                // TODO: trigger low stock alert if newStock < 5
            }
        }

        order.setStatus(newStatus);
        order.setUpdatedAt(LocalDateTime.now());
        return orderRepository.save(order);
    }
}
