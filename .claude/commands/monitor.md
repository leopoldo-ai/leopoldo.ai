# Monitor

Check the monitoring and analytics state of all Leopoldo services.

## Checks

1. **API health**: Hit /health endpoint, report status and latency
2. **Database**: Count rows in key tables (clients, purchases, page_views, metrics)
3. **Distribution**: Check distribution_state for pending updates
4. **Scout**: Summarize latest scout_findings (intelligence feed)
5. **Download activity**: Recent entries in download_log
6. **Error log**: Check api/monitoring/logger.py output if accessible

## Output

Present a monitoring dashboard with latest data points and any anomalies.
