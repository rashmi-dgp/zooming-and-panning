
#pragma once

#define GLFW_INCLUDE_NONE
#import <GLFW/glfw3.h>
#define GLFW_EXPOSE_NATIVE_COCOA
#import <GLFW/glfw3native.h>

#include <Metal/Metal.hpp>
#include <Metal/Metal.h>
#include <QuartzCore/CAMetalLayer.hpp>
#include <QuartzCore/CAMetalLayer.h>
#include <QuartzCore/QuartzCore.hpp>
#include <simd/simd.h>


#include "VertexData.hpp"
#include "Texture.hpp"
#include <stb/stb_image.h>

#include <iostream>
#include <filesystem>

class MTLEngine {
public:
    void init();
        void run();
        void cleanup();
        void resizeFrameBuffer(int width, int height);
        static void frameBufferSizeCallback(GLFWwindow* window, int width, int height);
        static void keyCallback(GLFWwindow* window, int key, int scancode, int action, int mods);
        static void cursorPosCallback(GLFWwindow* window, double xpos, double ypos);
        static void cursorPositionCallback(GLFWwindow* window, double xpos, double ypos);
private:
    void initDevice();
    void initWindow();
    
    void createSquare();
    void createDefaultLibrary();
    void createCommandQueue();
    void createRenderPipeline();
    
    void encodeRenderCommand(MTL::RenderCommandEncoder* renderEncoder);
    void sendRenderCommand();
    void draw();
    //added:
    void zoomIn();
    void zoomOut();
//    void updateCameraView();
    void updateCameraFocus(float xpos, float ypos);
       void updateCameraPosition();
    
    MTL::Device* metalDevice;
    GLFWwindow* glfwWindow;
    NSWindow* metalWindow;
    CAMetalLayer* metalLayer;
    CA::MetalDrawable* metalDrawable;
    
    MTL::Library* metalDefaultLibrary;
    MTL::CommandQueue* metalCommandQueue;
    MTL::CommandBuffer* metalCommandBuffer;
    MTL::RenderPipelineState* metalRenderPSO;
    MTL::Buffer* squareVertexBuffer;
    
    Texture* grassTexture;
    // Camera variables
        simd::float3 cameraPos;
        simd::float3 cameraFront;
        simd::float3 cameraUp;
        float fov;
    // Mouse cursor variables
        float lastX, lastY;
        float cursorX, cursorY;
};
