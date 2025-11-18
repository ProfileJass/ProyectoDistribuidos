CREATE TABLE IF NOT EXISTS users (
    id_user SERIAL PRIMARY KEY,
    "firstName" VARCHAR(255) NOT NULL,
    "lastName" VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    role VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

CREATE TABLE IF NOT EXISTS companies (
    id_company SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    nit VARCHAR(50) NOT NULL UNIQUE,
    address VARCHAR(255),
    phone VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payrolls (
    id_payroll SERIAL PRIMARY KEY,
    id_user INTEGER NOT NULL,
    id_company INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    FOREIGN KEY (id_company) REFERENCES companies(id_company) ON DELETE CASCADE
);

CREATE INDEX idx_payroll_id_user ON payrolls(id_user);
CREATE INDEX idx_payroll_id_company ON payrolls(id_company);
CREATE INDEX idx_payroll_status ON payrolls(status);

CREATE TABLE IF NOT EXISTS incapacities (
    id_incapacity SERIAL PRIMARY KEY,
    id_user INTEGER NOT NULL,
    id_payroll INTEGER NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('accidente', 'maternidad', 'enfermedad')),
    status VARCHAR(20) NOT NULL DEFAULT 'pendiente' CHECK (status IN ('pendiente', 'en trámite', 'confirmada', 'negada')),
    observacion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    FOREIGN KEY (id_payroll) REFERENCES payrolls(id_payroll) ON DELETE CASCADE
);

CREATE INDEX idx_incapacities_id_user ON incapacities(id_user);
CREATE INDEX idx_incapacities_id_payroll ON incapacities(id_payroll);
CREATE INDEX idx_incapacities_status ON incapacities(status);
CREATE INDEX idx_incapacities_start_date ON incapacities(start_date);

-- Insert default companies
INSERT INTO companies (name, nit, address, phone) VALUES
    ('Tech Solutions S.A.S', '900123456-7', 'Calle 100 #10-20, Bogotá', '+57 1 234 5678'),
    ('Innovación Digital Ltda', '800987654-3', 'Carrera 15 #85-40, Bogotá', '+57 1 876 5432'),
    ('Servicios Empresariales Colombia', '700456789-1', 'Avenida 68 #45-30, Bogotá', '+57 1 345 6789'),
    ('Consultoría Integral S.A.', '600321654-9', 'Calle 72 #10-34, Bogotá', '+57 1 654 3210'),
    ('Desarrollo y Tecnología', '500789123-4', 'Carrera 7 #32-16, Bogotá', '+57 1 789 0123')
ON CONFLICT (nit) DO NOTHING;

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_companies_updated_at
    BEFORE UPDATE ON companies
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payrolls_updated_at
    BEFORE UPDATE ON payrolls
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_incapacities_updated_at
    BEFORE UPDATE ON incapacities
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
