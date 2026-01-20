<?php
use OpenTelemetry\API\Trace\SpanKind;
use OpenTelemetry\API\Globals;

$tracer = Globals::tracerProvider()->getTracer('php-web');

// Create a span for this request
$span = $tracer->spanBuilder('handle_request')
    ->setSpanKind(SpanKind::KIND_SERVER)
    ->startSpan();

$scope = $span->activate();

try {
    // Output OTEL environment variables
    echo "=== OpenTelemetry Environment Variables ===\n";
    $otelVars = [];
    foreach ($_SERVER as $key => $value) {
        if (strpos($key, 'OTEL_') === 0) {
            $otelVars[$key] = $value;
        }
    }
    foreach (getenv() as $key => $value) {
        if (strpos($key, 'OTEL_') === 0 && !isset($otelVars[$key])) {
            $otelVars[$key] = $value;
        }
    }
    if (empty($otelVars)) {
        echo "No OTEL_ environment variables found.\n";
    } else {
        ksort($otelVars);
        foreach ($otelVars as $key => $value) {
            echo "$key = $value\n";
        }
    }
    echo "==========================================\n\n";
    
    // Your application logic
    echo "Hello World from PHP!\n";
    echo "Server Time: " . date('Y-m-d H:i:s') . "\n";
    echo "PHP Version: " . phpversion() . "\n";
    
    // Add span attributes
    $span->setAttribute('http.method', $_SERVER['REQUEST_METHOD'] ?? 'GET');
    $span->setAttribute('http.url', $_SERVER['REQUEST_URI'] ?? '/');
    $span->setAttribute('http.status_code', 200);
} finally {
    $span->end();
    $scope->detach();
}
