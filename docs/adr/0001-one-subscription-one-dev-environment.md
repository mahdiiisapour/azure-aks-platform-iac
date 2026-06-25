# ADR 0001: One Subscription and One Dev Environment

## Status

Accepted

## Date

2026-06-25

## Context

This project defines an Azure AKS platform reference architecture. The initial scope keeps the platform focused on a single non-production environment without taking on the full complexity and cost of an enterprise landing zone.

## Decision

Start with:

- One Azure subscription
- One non-production environment named `dev`
- West Europe as the Azure region
- One AKS cluster initially

## Rationale

One subscription and one environment keep the first platform version easy to reason about, rebuild, and destroy. This keeps the initial architecture focused on AKS, identity, networking, GitOps, and observability before introducing organisational scale.

West Europe is the initial region because it is close to the expected user location and supports the Azure services in scope.

One AKS cluster is enough to establish the main platform boundaries: cluster identity, node pools, network integration, observability, Key Vault access, and GitOps ownership.

## Alternatives Considered

### Multiple subscriptions

Multiple subscriptions are useful when separating platform, workload, security, production, and non-production concerns. They also help with billing, policy assignment, blast-radius control, and delegated ownership.

They are not chosen initially because they add management group, policy, identity, and networking decisions before the core AKS platform model is established.

### Full landing zone first

A full Azure landing zone is a better fit for enterprise production environments with central governance, connectivity, policy, logging, and security baselines.

It is not chosen initially because this project is scoped around the AKS platform baseline, not a full organisational cloud adoption programme.

### Multiple AKS clusters

Multiple clusters can be useful for stronger environment isolation, regional separation, specialised workload profiles, or independent upgrade schedules.

They are not chosen initially because a single dev cluster is enough to prove the architecture while keeping cost and operational overhead low.

## Consequences

The first platform version will be intentionally limited. It will not prove production-grade separation between environments or subscriptions.

This makes the project cheaper and easier to understand, but future production-like phases will need explicit decisions for subscription layout, environment isolation, policy inheritance, and multi-cluster operations.
