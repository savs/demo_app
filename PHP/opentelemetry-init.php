<?php
// OpenTelemetry initialization file
// This is auto-prepended to every PHP request

require_once __DIR__ . '/vendor/autoload.php';

use OpenTelemetry\SDK\Sdk;
use OpenTelemetry\SDK\Trace\TracerProvider;
use OpenTelemetry\SDK\Trace\SpanProcessor\SimpleSpanProcessor;
use OpenTelemetry\Contrib\Otlp\SpanExporter;
use OpenTelemetry\Contrib\Otlp\OtlpHttpTransportFactory;
use OpenTelemetry\SDK\Resource\ResourceInfo;
use OpenTelemetry\SDK\Resource\ResourceInfoFactory;
use OpenTelemetry\SDK\Common\Attribute\Attributes;

// Get OTLP endpoint from environment
$otlpEndpoint = getenv('OTEL_EXPORTER_OTLP_ENDPOINT') ?: 'http://alloy:4318';
$protocol = getenv('OTEL_EXPORTER_OTLP_PROTOCOL') ?: 'http/protobuf';

// Add /v1/traces path if not present and using HTTP
if ($protocol === 'http/protobuf' && strpos($otlpEndpoint, '/v1/traces') === false) {
    $otlpEndpoint = rtrim($otlpEndpoint, '/') . '/v1/traces';
}

// Create resource attributes
$resourceAttributes = [
    'service.name' => getenv('OTEL_SERVICE_NAME') ?: 'php-web',
    'service.namespace' => getenv('OTEL_SERVICE_NAMESPACE') ?: 'demo',
    'deployment.environment' => getenv('OTEL_ENVIRONMENT') ?: 'development',
];

if (getenv('SERVICE_VERSION')) {
    $resourceAttributes['service.version'] = getenv('SERVICE_VERSION');
}

// Parse OTEL_RESOURCE_ATTRIBUTES if set
if ($resourceAttrs = getenv('OTEL_RESOURCE_ATTRIBUTES')) {
    foreach (explode(',', $resourceAttrs) as $attr) {
        if (strpos($attr, '=') !== false) {
            list($key, $value) = explode('=', $attr, 2);
            $resourceAttributes[trim($key)] = trim($value);
        }
    }
}

// Create Attributes object from array
$attributes = Attributes::create($resourceAttributes);

// Create ResourceInfo with Attributes
$resource = ResourceInfo::create($attributes);

// Optionally merge with default resource
$resource = ResourceInfoFactory::defaultResource()->merge($resource);

// Create OTLP HTTP transport
$transport = (new OtlpHttpTransportFactory())->create($otlpEndpoint, 'application/x-protobuf');

// Create exporter
$exporter = new SpanExporter($transport);

// Create tracer provider with simple span processor
$tracerProvider = new TracerProvider(
    new SimpleSpanProcessor($exporter),
    null, // sampler (defaults to AlwaysOnSampler)
    $resource
);

// Register the global tracer provider using SDK builder
Sdk::builder()
    ->setTracerProvider($tracerProvider)
    ->buildAndRegisterGlobal();
