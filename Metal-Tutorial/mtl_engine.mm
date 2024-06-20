#include "mtl_engine.hpp"
#include "mtlm.h"
#include <cmath>

void MTLEngine::init() {
    initDevice();
    initWindow();
    
    createSquare();
    createDefaultLibrary();
    createCommandQueue();
    createRenderPipeline();
//     Initialization code...
    cameraPos = {0.0f, 0.0f, 3.0f};
    cameraFront = {0.0f, 0.0f, -0.05f};
    cameraUp = {0.0f, 1.0f, 0.0f};
        fov = 45.0f;
    
    // Set GLFW callbacks
    glfwSetKeyCallback(glfwWindow, keyCallback);
    glfwSetCursorPosCallback(glfwWindow, cursorPositionCallback);
    
    // Initialize last cursor position
        double xpos, ypos;
        glfwGetCursorPos(glfwWindow, &xpos, &ypos);
        lastX = static_cast<float>(xpos);
        lastY = static_cast<float>(ypos);
        cursorX = 5.0f;
        cursorY = 5.0f;
}

//float rotationAngle = 0.0f;

void MTLEngine::run() {
    while (!glfwWindowShouldClose(glfwWindow)) {
        @autoreleasepool {
            metalDrawable = (__bridge CA::MetalDrawable*)[metalLayer nextDrawable];
            draw();
//            rotationAngle += 0.00f;
        }
        glfwPollEvents();
    }
}


void MTLEngine::cleanup() {
    glfwTerminate();
    metalDevice->release();
    delete grassTexture;
}

void MTLEngine::initDevice() {
    metalDevice = MTL::CreateSystemDefaultDevice();
}

void MTLEngine::frameBufferSizeCallback(GLFWwindow *window, int width, int height) {
    MTLEngine* engine = (MTLEngine*)glfwGetWindowUserPointer(window);
    engine->resizeFrameBuffer(width, height);
}

void MTLEngine::resizeFrameBuffer(int width, int height) {
    metalLayer.drawableSize = CGSizeMake(width, height);
}

void MTLEngine::initWindow() {
    glfwInit();
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    glfwWindow = glfwCreateWindow(800, 600, "Metal Engine", NULL, NULL);
    
    if (!glfwWindow) {
        glfwTerminate();
        exit(EXIT_FAILURE);
    }
    
    glfwSetWindowUserPointer(glfwWindow, this);
    glfwSetFramebufferSizeCallback(glfwWindow, frameBufferSizeCallback);
    int width, height;
    glfwGetFramebufferSize(glfwWindow, &width, &height);
    
    metalWindow = glfwGetCocoaWindow(glfwWindow);
    metalLayer = [CAMetalLayer layer];
    metalLayer.device = (__bridge id<MTLDevice>)metalDevice;
    metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    metalLayer.drawableSize = CGSizeMake(width, height);
    metalWindow.contentView.layer = metalLayer;
    metalWindow.contentView.wantsLayer = YES;
}

void MTLEngine::createSquare() {
    VertexData squareVertices[] {
        {{-0.5, -0.5,  0.5, 1.0f}, {0.0f, 0.0f}},
        {{-0.5,  0.5,  0.5, 1.0f}, {0.0f, 1.0f}},
        {{ 0.5,  0.5,  0.5, 1.0f}, {1.0f, 1.0f}},
        {{-0.5, -0.5,  0.5, 1.0f}, {0.0f, 0.0f}},
        {{ 0.5,  0.5,  0.5, 1.0f}, {1.0f, 1.0f}},
        {{ 0.5, -0.5,  0.5, 1.0f}, {1.0f, 0.0f}}
    };
    
    squareVertexBuffer = metalDevice->newBuffer(&squareVertices, sizeof(squareVertices), MTL::ResourceStorageModeShared);

    // Make sure to change working directory to Metal-Tutorial root
    // directory via Product -> Scheme -> Edit Scheme -> Run -> Options
    grassTexture = new Texture("assets/mc_grass.jpeg", metalDevice);
}

void MTLEngine::createDefaultLibrary() {
    metalDefaultLibrary = metalDevice->newDefaultLibrary();
    if(!metalDefaultLibrary){
        std::cerr << "Failed to load default library.";
        std::exit(-1);
    }
}

void MTLEngine::createCommandQueue() {
    metalCommandQueue = metalDevice->newCommandQueue();
}

void MTLEngine::createRenderPipeline() {
    MTL::Function* vertexShader = metalDefaultLibrary->newFunction(NS::String::string("vertexShader", NS::ASCIIStringEncoding));
    assert(vertexShader);
    MTL::Function* fragmentShader = metalDefaultLibrary->newFunction(NS::String::string("fragmentShader", NS::ASCIIStringEncoding));
    assert(fragmentShader);
    
    MTL::RenderPipelineDescriptor* renderPipelineDescriptor = MTL::RenderPipelineDescriptor::alloc()->init();
    renderPipelineDescriptor->setVertexFunction(vertexShader);
    renderPipelineDescriptor->setFragmentFunction(fragmentShader);
    assert(renderPipelineDescriptor);
    MTL::PixelFormat pixelFormat = (MTL::PixelFormat)metalLayer.pixelFormat;
    renderPipelineDescriptor->colorAttachments()->object(0)->setPixelFormat(pixelFormat);
        
    NS::Error* error;
    metalRenderPSO = metalDevice->newRenderPipelineState(renderPipelineDescriptor, &error);
    
    renderPipelineDescriptor->release();
}

void MTLEngine::draw() {
    sendRenderCommand();
}
float t = 0.0f;
void MTLEngine::sendRenderCommand() {
    metalCommandBuffer = metalCommandQueue->commandBuffer();
    
    MTL::RenderPassDescriptor* renderPassDescriptor = MTL::RenderPassDescriptor::alloc()->init();
    MTL::RenderPassColorAttachmentDescriptor* cd = renderPassDescriptor->colorAttachments()->object(0);
    
    cd->setTexture(metalDrawable->texture());
    cd->setLoadAction(MTL::LoadActionClear);
    cd->setClearColor(MTL::ClearColor(41.0f/255.0f, 42.0f/255.0f, 48.0f/255.0f, 1.0));
    cd->setStoreAction(MTL::StoreActionStore);
    
    MTL::RenderCommandEncoder* renderCommandEncoder = metalCommandBuffer->renderCommandEncoder(renderPassDescriptor);
    encodeRenderCommand(renderCommandEncoder);
    renderCommandEncoder->endEncoding();

    metalCommandBuffer->presentDrawable(metalDrawable);
    metalCommandBuffer->commit();
    metalCommandBuffer->waitUntilCompleted();
    
    renderPassDescriptor->release();
}
//-------------original----------------
void MTLEngine::encodeRenderCommand(MTL::RenderCommandEncoder* renderCommandEncoder) {
//    simd::float4x4 view = mtlm::lookAt(cameraPos, cameraPos + cameraFront, cameraUp);
//       simd::float4x4 projection = mtlm::perspective(mtlm::radians(fov), 800.0f / 600.0f, 0.1f, 100.0f);
//       simd::float4x4 transform = projection * view * mtlm::identity();
//
//       renderCommandEncoder->setVertexBytes(&transform, sizeof(simd::float4x4), 1);
//       renderCommandEncoder->setRenderPipelineState(metalRenderPSO);
//       renderCommandEncoder->setVertexBuffer(squareVertexBuffer, 0, 0);
//       MTL::PrimitiveType typeTriangle = MTL::PrimitiveTypeTriangle;
//       NS::UInteger vertexStart = 0;
//       NS::UInteger vertexCount = 6;
//       renderCommandEncoder->setFragmentTexture(grassTexture->texture, 0);
//       renderCommandEncoder->drawPrimitives(typeTriangle, vertexStart, vertexCount);
    
    // Create view matrix
        simd::float4x4 view = mtlm::lookAt(cameraPos, cameraPos + cameraFront, cameraUp);
        // Create projection matrix
        simd::float4x4 projection = mtlm::perspective(fov, 800.0f / 600.0f, 0.1f, 100.0f);
        // Create model matrix
        simd::float4x4 model = mtlm::identity();
        // Compute MVP matrix
        simd::float4x4 mvp = projection * view * model;
        
        renderCommandEncoder->setRenderPipelineState(metalRenderPSO);
        renderCommandEncoder->setVertexBuffer(squareVertexBuffer, 0, 0);
        renderCommandEncoder->setVertexBytes(&mvp, sizeof(mvp), 1);
        
        MTL::PrimitiveType typeTriangle = MTL::PrimitiveTypeTriangle;
        NS::UInteger vertexStart = 0;
        NS::UInteger vertexCount = 6;
        renderCommandEncoder->setFragmentTexture(grassTexture->texture, 0);
        renderCommandEncoder->drawPrimitives(typeTriangle, vertexStart, vertexCount);
}

void MTLEngine::zoomIn() {
    if (fov > 1.0f) fov -= 0.01f;
}

void MTLEngine::zoomOut() {
    if (fov < 45.0f) fov += 0.01f;
}

void MTLEngine::keyCallback(GLFWwindow* window, int key, int scancode, int action, int mods) {
    if (action == GLFW_PRESS || action == GLFW_REPEAT) {
        MTLEngine* engine = (MTLEngine*)glfwGetWindowUserPointer(window);
        switch (key) {
            case (GLFW_KEY_UP):
                engine->zoomIn();
                break;
            case (GLFW_KEY_DOWN):
                engine->zoomOut();
                break;
            default:
                break;
        }
    }
}
void MTLEngine::cursorPositionCallback(GLFWwindow* window, double xpos, double ypos) {
    MTLEngine* engine = (MTLEngine*)glfwGetWindowUserPointer(window);
    engine->updateCameraFocus(static_cast<float>(xpos), static_cast<float>(ypos));
}

void MTLEngine::updateCameraFocus(float xpos, float ypos) {
    // Convert cursor position to normalized device coordinates
    float x = (2.0f * xpos) / 800.0f - 1.0f;
    float y = 1.0f - (2.0f * ypos) / 600.0f;
    
    cursorX = x;
    cursorY = y;
    
    // Update camera position
    updateCameraPosition();
}

void MTLEngine::updateCameraPosition() {
    // Adjust the camera target position based on cursor position
    cameraPos.x = cursorX;
    cameraPos.y = cursorY;
}
