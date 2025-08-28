import psycopg2

conn = psycopg2.connect(
    host="localhost",
    database="some_data",
    user="db_user",
    password="db_p4ssw0rd",
    port="5432" 
)

def send_sql_query(username: str, password: str):

    cur = conn.cursor()

    # Purposefully vulnerable!
    query = f"""
        INSERT INTO
            organization.users (username, password) 
        VALUES
            ({username}, {password})
    """

    cur.execute(query)
    conn.commit()

if __name__ == '__main__':
    send_sql_query("alice", "4l1c3p4ssw0rd")
    