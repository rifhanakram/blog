---
layout: post
title: "My AWS IAM Playbook: 6 Lessons from the Trenches"
date: 2025-09-16
categories: [tech]
---

# My AWS IAM Playbook: 6 Lessons from the Trenches

![Panicked engineers after production is compromised](/static/img/my-iam-playbook.png)
*AI Generated Image by Gemini Nano Banana*

After years of working with software companies and startups, I've seen a clear pattern. The teams that move fastest and sleep best at night are the ones who took Identity and Access Management (IAM) seriously from day one. It's the bedrock of a secure and scalable cloud environment.

Based on my experience, this isn't just a list of best practices. This is my non-negotiable playbook for getting IAM right from the day one.

### 1. The First Thing I Check: Is MFA on Everything?

When I start working in a project, the very first thing I look at is the MFA status. It tells alot about security posture and thinking. Seeing a root account without Multi-Factor Authentication is a red flag.

A password is just a single, fragile key. MFA is the deadbolt. If a password gets compromised (and it will), MFA is the only thing standing between an attacker and your entire AWS kingdom. My rule is simple: MFA isn't just for the root user. It's for **every single human user** in the account. No exceptions.

**Monitoring Tip:** Set up CloudWatch alarms for any console sign-ins without MFA. Create an SNS notification for root account usage—this should be rare enough that any alert warrants immediate investigation.

### 2. Don't Learn This Lesson the Hard Way: Rotate Your Access Keys

I once worked in a project that was dealing with a account being compromised and unidentified compute resources running. It turned out to be an old access key from a developer who had left the project six months prior. The key, which had been accidentally committed to a private GitHub repo that was later made public, was still active. 

Long-lived, static credentials are a ticking time bomb. My advice is firm: enforce a **90-day rotation policy** for all programmatic access keys. If a key is leaked, this rule ensures it becomes useless in a matter of weeks, not years. Use tools like [IAM Access Analyzer](https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html) to find and delete old, unused keys—it's one of the easiest security wins you can get.

**Compliance Note:** If you're pursuing SOC2 or PCI-DSS compliance, key rotation policies are often mandatory. SOC2 typically requires 90-day rotation, while PCI-DSS may require more frequent rotation for high-privilege accounts.

### 3. The Most Dangerous Habit I See: Using the Root User

I still see founders and key stakeholders using the AWS account root user for daily tasks. This is like using the master key for a skyscraper to open your office door every day. It's unnecessarily risky.

The root user is a "break glass in case of emergency" account. My process with every AWS account is the same:
1.  Put MFA on the root account immediately.
2.  Create a dedicated IAM user with `AdministratorAccess`.
3.  Use *that* user for daily admin work.
4.  Lock the root credentials away in a secure vault.

You should only touch the root user for a handful of specific billing or account-level tasks. Period.

**Monitoring Alert:** Configure Access Analyzer to send immediate notifications for any root user API calls. If you see `RootAccountUsage` events in CloudTrail, investigate immediately.

### 4. Stop the "Privilege Creep" Before It Starts: Use Groups for Users, Roles for Services

The most chaotic IAM setups I've ever had to untangle are the ones where permissions were attached directly to individual users. As people change roles or leave, it becomes a mess of forgotten access and overly permissive accounts—a phenomenon called "privilege creep."

For human users, I always guide teams to think in terms of groups, not individuals. Create IAM Groups like `Developers`, `QualityEngineers`, or `ReadOnlyAdmins`. Attach well-defined policies to these groups. When a new engineer joins, you add them to the appropriate group. It's clean, auditable, and scales beautifully.

**Troubleshooting Tip:** If users report "Access Denied" errors, use the IAM Policy Simulator to test their effective permissions. Check CloudTrail logs for the exact API call that failed—the error message often reveals which specific permission is missing.

### 5. The Cardinal Sin: Hardcoded Credentials

If there's one mistake that truly keeps me up at night, it's seeing access keys hardcoded in an application's source code or config files. It's the digital equivalent of taping your house key to the front door.

The solution is **IAM Roles for Services**. Instead of giving your EC2 instance or Lambda function a static access key, you assign it a role. When your application assumes this role, AWS Security Token Service (STS) provides temporary credentials that are automatically rotated every few hours. Your code gets the access it needs through the instance metadata service or Lambda execution environment, and there are no static keys to be stolen.

**Common Error:** "Unable to locate credentials" usually means your EC2 instance or Lambda function doesn't have an IAM role attached, or the SDK isn't configured to use the instance profile credentials.

### 6. The "Graduation" Moment: Moving to a Multi-Account Strategy

In my mind, a startup truly "graduates" to a professional cloud setup the day they move from one chaotic AWS account to a multi-account organization. I've seen the horror stories—a script run in a dev environment accidentally taking down a prod server because there was no separation.

A multi-account strategy makes that class of error impossible. By creating separate accounts for Dev, Staging, and Production under AWS Organizations, you create powerful security boundaries. You manage your users centrally and use cross-account [IAM Roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html) to let them switch into different environments. This isolates your workloads and is the single most effective way to limit the blast radius of any incident.

**Compliance Alignment:** Multi-account separation directly supports several compliance requirements:
- **SOC2**: Logical access controls and environment separation
- **PCI-DSS**: Network segmentation and production/non-production isolation  
- **HIPAA**: Minimum necessary access and audit controls

**Debugging Cross-Account Access:** If role assumption fails with "Access Denied," check three things: 1) The trust relationship in the target account's role, 2) The AssumeRole permission in the source account, and 3) Any SCP restrictions at the Organizations level.

### My Final Take

Building a secure AWS foundation isn't about complex tools. It's about following these core principles consistently. The time you spend setting up IAM correctly today will save you from major headaches later.

Remember: Good IAM practices aren't just about security—they're about maintaining velocity while keeping your infrastructure manageable. When inevitably something goes wrong (and it will), proper IAM setup ensures it's a minor incident, not a headline.