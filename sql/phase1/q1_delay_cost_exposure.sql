SELECT f.aircraft_id, DATE(f.scheduled_departure) AS flight_date, COUNT(f.flight_id) AS total_flights,
    SUM(
        CASE 
            WHEN f.actual_arrival IS NULL THEN 0
            ELSE TIMESTAMPDIFF(MINUTE,f.scheduled_arrival,f.actual_arrival) 
		END) AS total_delay_minutes,
    
    SUM(COALESCE(fc.delay_penalty_cost, 0)) AS total_delay_penalty_cost,
    
    SUM(
        COALESCE(fc.fuel_cost, 0)
      + COALESCE(fc.crew_cost, 0) + COALESCE(fc.airport_fee, 0) + COALESCE(fc.delay_penalty_cost, 0)
    ) AS total_operating_cost,
    
SUM(COALESCE(pl.boarded_seats, 0))/NULLIF(SUM(pl.capacity), 0)
AS load_factor_percentage

FROM Flightsss f
LEFT JOIN flight_costs as fc  ON f.flight_id = fc.flight_id
LEFT JOIN passenger_load as pl ON f.flight_id = pl.flight_id
WHERE f.status = 'completed'
GROUP BY f.aircraft_id, DATE(f.scheduled_departure)
ORDER BY f.aircraft_id, flight_date;

#Question : flight_cost_analysis

SELECT
    flight_id, load_proxy_metric, total_cost, cost_per_boarded_seat
FROM (
    SELECT
        f.flight_id,

        COALESCE(pl.boarded_seats, 0) AS load_proxy_metric,

        COALESCE(fc.fuel_cost, 0) + COALESCE(fc.crew_cost, 0) + COALESCE(fc.airport_fee, 0) + COALESCE(fc.delay_penalty_cost, 0) AS total_cost,

        (
            COALESCE(fc.fuel_cost, 0) + COALESCE(fc.crew_cost, 0) + COALESCE(fc.airport_fee, 0) + COALESCE(fc.delay_penalty_cost, 0)
        )/ NULLIF(COALESCE(pl.boarded_seats, 0), 0) AS cost_per_boarded_seat,

        ROW_NUMBER() OVER (
            ORDER BY
                (
                    COALESCE(fc.fuel_cost, 0) + COALESCE(fc.crew_cost, 0) + COALESCE(fc.airport_fee, 0) + COALESCE(fc.delay_penalty_cost, 0)
                )/ NULLIF(COALESCE(pl.boarded_seats, 0), 0) DESC) AS rn

    FROM flightsss f
    LEFT JOIN passenger_load pl
           ON f.flight_id = pl.flight_id
    LEFT JOIN flight_costs fc
           ON f.flight_id = fc.flight_id) ranked
WHERE rn <= 3;