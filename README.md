# Insightfuls_01
Development of an idea that reduces DevOoops and promotes a competence in DevOps. 

# Background
Site reliablility is of primary importance for internet businesses. The company not only loses the revenue stream when a site is unavailable, but also depletes from its user base and fails to attract new customers. The industry best practices describe distributing servers across multiple availability zones, allowing data transfer across a low-latency connection to a mirrored server that remains ready as a backup. 
The largest webservices companies provide centers (or availability zones) across distinct geographical areas within a region. Though, entire regions can fail, and have done so due to various occurrences. Most often these occurrences involve administrator error. Though, natural disasters are likely to play more prominently in site-availability concerns as hurricanes reach further north along the North American coast and fires rage through the west. 
The time to recover from a regional outage leaves a company dependent on the web services provider to resolve the problem or an estimated 24-hour period required for the recursive name servers to update it's collective cache if the user decides to mitigate the consequences by launching a new server. 

# Problem
Resolving a fallen region could take an unpredictable amount of time for a service provider to fix the facility or as long as 24-hours to resolve a new IP address. 

# Solution
Try to use the recursive DNS servers' eventual consistency to reduce the downtime of users in a stricken region by serving duplicate IP addresses to a single region. 

