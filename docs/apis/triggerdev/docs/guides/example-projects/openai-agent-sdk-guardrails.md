---
source: https://trigger.dev/docs/guides/example-projects/openai-agent-sdk-guardrails
scraped: 2026-02-28
---

# OpenAI Agents SDK for Python Guardrails

## Overview

This demonstration illustrates practical implementation of safety mechanisms for AI agents. The project showcases three distinct types of guardrails: input validation, output checking, and real-time streaming monitoring.

The example integrates the OpenAI Agent SDK for Python with Trigger.dev to enable production-ready AI workflows. Key aspects include:

- Validating user inputs before processing
- Checking generated responses for quality and safety
- Monitoring streamed content in real-time
- Preventing unwanted or harmful agent behavior
- Real-world scenarios such as educational tutoring agents with content validation

## Core Components

### Trigger.dev Tasks (TypeScript)

- **inputGuardrails.ts** - Sends user prompts to a Python script and manages `InputGuardrailTripwireTriggered` exceptions
- **outputGuardrails.ts** - Runs agent generation while catching `OutputGuardrailTripwireTriggered` exceptions with comprehensive error details
- **streamingGuardrails.ts** - Executes a streaming Python script and processes JSON output containing guardrail metrics

### Python Implementations

- **input-guardrails.py** - Uses `@input_guardrail` decorator to validate inputs before agent processing (e.g., math tutoring that only responds to math questions)
- **output-guardrails.py** - Employs `@output_guardrail` decorator to validate responses using a separate guardrail agent
- **streaming-guardrails.py** - Processes `ResponseTextDeltaEvent` streams with asynchronous guardrail checks at configurable intervals

## Resources

- [GitHub repository](https://github.com/triggerdotdev/examples/tree/main/openai-agent-sdk-guardrails-examples) with complete source code
- [OpenAI Agent SDK documentation](https://openai.github.io/openai-agents-python/)
- [OpenAI guardrails guide](https://openai.github.io/openai-agents-python/guardrails/)
